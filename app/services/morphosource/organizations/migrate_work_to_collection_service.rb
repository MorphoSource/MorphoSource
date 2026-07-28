module Morphosource
  module Organizations
    # Migrates organization work to organization collection
    class MigrateWorkToCollectionService
      include Morphosource::ResqueJobsHelper

      attr_reader :organization_work_id, :organization_work, :organization_collection_id,
        :organization_collection, :organization_team_id, :organization_team, :data, :all_media_ids,
        :organization_metadata

      def initialize(organization_work_id)
        @organization_work_id = organization_work_id
        @organization_work = Organization.find(organization_work_id)

        @organization_team = organization_work.team
        @organization_team_id = organization_team&.id

        @organization_collection = OrganizationCollection.where(
          legacy_organization_work_id: organization_work_id
        )&.first
        @organization_collection_id = organization_collection&.id

        @all_media_ids = []
        @organization_metadata = get_organization_metadata
      end

      # @!group Initialization

      # Get metadata hash from organization work and team, using priority rules
      def get_organization_metadata
        org_coll_metadata = {}

        # Merge metadata from team
        if organization_team.present?
          org_coll_metadata.merge!(
            attributes_copied_from_team.map(&:to_sym).map do |attr|
              [attr, organization_team.send(attr)]
            end.to_h
          )
        end

        # Merge metadata from org
        org_coll_metadata.merge!(
          attributes_copied_from_organization.map(&:to_sym).map do |attr|
            [attr, organization_work.send(attr)]
          end.to_h
        )

        # Special case for related_url and description fields
        org_coll_metadata[:related_url] = ( organization_work.related_url + (organization_team&.related_url || []) ).uniq

        desc = nil
        if organization_work.description&.first.present? && organization_team&.description&.first.present?
          # combine the two, with team description first
          desc = "#{organization_team&.description&.first}\n\n#{organization_work.description&.first}"
        else
          # use whichever is present
          desc = organization_team&.description&.first.presence || organization_work&.description&.first.presence
        end
        org_coll_metadata[:description] = [desc] if desc.present?

        return org_coll_metadata
      end

      # For these attributes, value from team is primary
      def attributes_copied_from_team
        ["creator", "contributor", "keyword",  "publisher", "subject", "language", "identifier", "based_near", "bibliographic_citation", "source", "can_submit_remote_files", "allowed_remote_source"]
      end

      # For these attributes, value from org is primary
      def attributes_copied_from_organization
        ["title", "organization_type", "institution_code", "postal_code", "contact_person", "institution_name", "collection_code", "recordset_id", "permissions_enforcement_mode", "download_permission", "rights_holder_blank", "license_blank", "rights_statement_blank", "download_reviewer", "agreement_uri", "morphosource_use_agreement_type", "required_archival_of_published_derivatives", "permits_commercial_use", "permits_3d_use", "rights_holder", "preview_mode", "address", "city", "state_province", "country", "license", "rights_statement", "date_managed"]
      end

      # @!endgroup

      # @!group Migration

      # PHASE 1. Migrate organization work (and team) to organization collection.
      def migrate
        ### STEP 1. Create Organization Collection ###
        Rails.logger.info "STEP 1. Create Organization Collection"

        if !organization_collection.present?
          @organization_collection = OrganizationCollection.create(
            organization_metadata.merge(
              visibility: 'open',
              depositor: batch_user.user_key,
              legacy_organization_work_id: organization_work.id
          ))
          organization_collection.create_collection_groups
          Morphosource::Collections::PermissionsCreateService.create_default(collection: organization_collection)
          @organization_collection_id = organization_collection.id
        end

        ### STEP 2. If data manager present, make that user an org manager and turn org transfer ON ###
        Rails.logger.info "STEP 2. If data manager present, make that user an org manager and turn org transfer ON"

        org_data_manager = nil
        if organization_work&.data_manager&.first.present?
          org_data_manager = User.find_by_user_key(organization_work&.data_manager&.first)
          organization_collection.managers << org_data_manager unless organization_collection.managers.include?(org_data_manager)
          organization_collection.media_ownership_transfer = true
          organization_collection.save
        end

        ### STEP 3. Copy members and move projects from teams ###
        Rails.logger.info "STEP 3. Copy members and move projects from teams"

        if organization_team.present?
          # Add team members as org members (unless member is data manager, because we handled that already)
          roles = [:managers, :editors, :depositors, :downloaders, :viewers]
          roles.each do |role|
            (organization_team.send(role) || []).each do |user|
              if user.id.present? && (user.id != org_data_manager&.id) && (!organization_collection.send(role).include?(user))
                organization_collection.send(role) << user
              end
            end
          end

          # Remove batch user as org collection manager
          organization_collection.managers.delete(batch_user)

          # Copy team projects over
          if ( team_projects = Collection.where("member_of_collection_ids_ssim:#{organization_team.id}") ).present?
            team_projects.each do |project|
              raise "Unexpected team project record" if !project.is_a?(Collection)
              project.member_of_collections = [organization_collection]
              project.save!
            end
            organization_team.save!
          end
        end

        # Preserve the legacy management date when a non-admin manager exists.
        # Otherwise, OrganizationCollection derives (or clears) it from the
        # newly assigned managers.
        organization_collection.reload
        if organization_collection.managed_by_non_admin? && organization_work.date_managed.present? && organization_collection.date_managed != organization_work.date_managed
          organization_collection.date_managed = organization_work.date_managed
          organization_collection.save!
        end

        ### STEP 4. All media associated with the org and owned by the data manager should be owned by the organization directly ###
        # Note: Because we have to check org association, this has to be done before moving records to associate with new org
        Rails.logger.info "STEP 4. All media associated with the org and owned by the data manager should be owned by the organization directly"

        if org_data_manager.present?
          data_manager_media = Media.where("media_organization_id_ssim": organization_work.id, "user_with_ownership_ssi": org_data_manager.user_key)
          data_manager_media.each do |media|
            ContentDepositorChangeEventJob.set(
              queue: Hyrax.config.update_medium_queue_name
            ).perform_later(media, organization_collection.id, false, org_data_manager.id)
          end
        end

        ### STEP 5. Copy over team thumbnail, banner, logo, and URI agreement attachment ###
        Rails.logger.info "STEP 5. Copy over team thumbnail, banner, logo, and URI agreement attachment"

        if organization_team.present?
          # representative ID (thumbnail on form)
          if organization_team.representative_id.present?
            organization_collection.representative_id = organization_team.representative_id
          end
          # thumbnail ID
          if organization_team.thumbnail_id.present?
            organization_collection.thumbnail_id = organization_team.thumbnail_id
          end

          # banner and logo image
          CollectionBrandingInfo.where(collection_id: organization_team.id).each do |info|
            old_file_path = info.local_path.sub("/opt/morphosource/root/", "/app/samvera/hyrax-webapp/")
            info.collection_id = organization_collection.id
            # info.local_path = info.find_local_filename(info.collection_id, info.role, File.basename(old_file_path))
            info.save(old_file_path) # will delete old version of file
          end

          # Does organization have agreement URI attachment supplied?
          if organization_work.agreement_attachment_url.present?
            file_path = organization_work.agreement_attachment_full_path
            if File.exist?(file_path)
              file = ActionDispatch::Http::UploadedFile.new(
                filename: File.basename(file_path),
                type: Marcel::MimeType.for(file_path),
                tempfile: File.open(file_path)
              )
              organization_collection.agreement_attachment = file
            end
            raise "Issue creating agreement attachment for organization collection" if !organization_collection.agreement_attachment_url.present?
            end
        end

        # Save after steps 2-5
        organization_collection.save!

        ### STEP 6. If non-organization team media exist, move them to a custom project
        Rails.logger.info "STEP 6. If non-organization team media exist, move them to a custom project"

        if organization_team.present?
          # First, save organization team member media IDs for later reindexing
          all_media_ids.concat ActiveFedora::SolrService.query(
            "has_model_ssim:Media && member_of_collection_ids_ssim:#{organization_team.id}", rows: 999999, fl: ["id"]
          ).map { |doc| doc['id'] }

          # Need to search negative condition, can't use Media.where
          non_organization_team_media_docs = ActiveFedora::SolrService.query(
            "member_of_collection_ids_ssim:#{organization_team.id} AND -media_organization_id_ssim:#{organization_work.id}",
            rows: 999999
          )
          non_organization_team_media_ids = non_organization_team_media_docs.map { |d| d["id"] }

          # all organization media owned by the team should be removed from the team
          # doing this here instead of at team deletion so we can check that the media are removed before completing migration
          # Use ModifyCollectionMembershipJob instead of RemoveCollectionMembersJob to bypass reapply_org_team_access method
          organization_team_media_ids = all_media_ids - non_organization_team_media_ids
          organization_team_media_ids.each do |organization_team_media_id|
            ModifyCollectionMembershipJob.set(
              queue: Hyrax.config.update_slow_queue_name
            ).perform_later(
              media_id: organization_team_media_id,
              add_to_collection_ids: [],
              remove_from_collection_ids: [organization_team.id]
            )
          end

          if non_organization_team_media_docs.present?
            # create the custom project
            custom_project = Collection.create(
              title: ["Editable media not associated with #{organization_collection.title.first}"],
              visibility: 'restricted',
              description: ["This project was automatically created during an organization migration for the organization #{organization_collection.title.first}. It contains all media that were both previously present in the organization team and also not associated with the organization through a physical object. These media can be edited by organization members with appropriate membership roles, but they will appear in this project and not on the organization page."],
              collection_type_gid: Hyrax::CollectionType.where({:title => 'Project'})&.first.to_global_id,
              depositor: organization_collection.depositor
            )
            custom_project.create_collection_groups
            Morphosource::Collections::PermissionsCreateService.create_default(collection: custom_project)

            # Add custom project to org collection
            custom_project.member_of_collections << organization_collection

            # Ensure custom project has same members as parent!
            roles = [:managers, :editors, :depositors, :downloaders, :viewers]
            roles.each do |role|
              (organization_collection.send(role) || []).each do |user|
                custom_project.send(role) << user
              end
            end
            custom_project.managers.delete(batch_user)

            # Save everything
            custom_project.save!
            organization_collection.save!

            # associate media with this project and not with the team
            non_organization_team_media_ids.each do |non_organization_team_media_id|
              ModifyCollectionMembershipJob.set(
                queue: Hyrax.config.update_slow_queue_name
              ).perform_later(
                media_id: non_organization_team_media_id,
                add_to_collection_ids: [custom_project.id],
                remove_from_collection_ids: [organization_team.id]
              )
            end

            # all media with team access grants need to have those grants removed
            team_access_media_ids = SolrDocument.where("has_model_ssim:Media AND
                                                        read_access_group_ssim:#{organization_team.id}_* OR
                                                        download_access_group_ssim:#{organization_team.id}_* OR
                                                        edit_access_group_ssim:#{organization_team.id}_*").map{|d| d["id"] }

            team_access_media_ids -= all_media_ids # team member media should have their access grants removed above by the ModifyCollectionMembershipJob

            team_access_media_ids.each do |team_access_media_id|
              Morphosource::RemoveCollectionAccessGrantsJob.perform_later(collection_id: organization_team.id, work_id: team_access_media_id)
            end
          end
        end

        ### STEP 7. Move all devices from organization ###
        Rails.logger.info "STEP 7. Move all devices from organization"

        # Gather devices based on parent/child and ID relationships
        devices = (
          organization_work.devices +
          DeviceResource.where(organization_id: organization_work.id)
        ).uniq { |device| device.id.to_s }

        # Get media IDs associated with devices for later reindexing
        device_ids = devices.map(&:id)
        if device_ids.present?
          all_media_ids.concat Morphosource::SolrService.new.get_docs(
            "has_model_ssim:Media && media_device_id_ssim:(#{device_ids.join(' OR ')})", {rows: 999999, fl: ["id"]}
          ).map { |doc| doc['id'] }
        end

        devices.each do |device|
          device.organization_id = [organization_collection.id]
          device.skip_index_related_works = true # we'll reindex manually later
          device.save!
        end
        organization_work.members = []
        organization_work.ordered_members = []
        organization_work.save!

        ### STEP 8. Move all biological specimens from organization
        Rails.logger.info "STEP 8. Move all biological specimens from organization"

        biological_specimens = SolrDocument.where(
          { "has_model_ssim" => "BiologicalSpecimen", "organization_id_ssim" => organization_work.id },
          opts: { sort: "system_create_dtsi ASC", rows: 999999 }
        )

        # Get BSO and BSO media IDs for later reindexing
        biological_specimen_ids = biological_specimens.map { |doc| doc['id'] }
        biological_specimen_ids.each_slice(250) do |id_batch|
          all_media_ids.concat Morphosource::SolrService.new.get_docs(
            "has_model_ssim:Media && physical_object_id_ssim:(#{id_batch.join(' OR ')})", {rows: 999999, fl: ["id"]}
          ).map { |doc| doc['id'] }
        end

        biological_specimens.each do |biological_specimen|
          UpdateBiologicalSpecimenMetadataJob.set(
            queue: Hyrax.config.update_slow_queue_name
          ).perform_later(
            { id: [biological_specimen.id], organization_id: [organization_collection.id] },
            skip_index_related_works: true # skip reindexing, we'll handle this manually
          )
        end

        ### STEP 9. Move all cultural heritage objects from organization
        Rails.logger.info "STEP 9. Move all cultural heritage objects from organization"

        cultural_heritage_objects = SolrDocument.where(
          { "has_model_ssim" => "CulturalHeritageObject", "organization_id_ssim" => organization_work.id },
          opts: { sort: "system_create_dtsi ASC", rows: 999999 }
        )

        # Get CHO and CHO media IDs for later reindexing
        cultural_heritage_object_ids = cultural_heritage_objects.map { |doc| doc['id'] }
        cultural_heritage_object_ids.each_slice(250) do |id_batch|
          all_media_ids.concat Morphosource::SolrService.new.get_docs(
            "has_model_ssim:Media && physical_object_id_ssim:(#{id_batch.join(' OR ')})", {rows: 999999, fl: ["id"]}
          ).map { |doc| doc['id'] }
        end

        cultural_heritage_objects.each do |cultural_heritage_object|
          # N.b. this job also works for CHOs!
          UpdateBiologicalSpecimenMetadataJob.set(
            queue: Hyrax.config.update_slow_queue_name
          ).perform_later(
            { id: [cultural_heritage_object.id], organization_id: [organization_collection.id] },
            skip_index_related_works: true # skip reindexing, we'll handle this manually
          )
        end

        # As a last check to find any media missed, query all media associated with the organization work or collection
        org_media_ids = ActiveFedora::SolrService.query(
          "has_model_ssim:Media && media_organization_id_ssim:#{organization_work.id}", rows: 999999, fl: ["id"]
        ).map { |doc| doc['id'] }
        all_media_ids.concat org_media_ids

        # Wait until step 8 and 9 complete before moving on
        wait_until_no_jobs("UpdateBiologicalSpecimenMetadataJob")

        ### STEP 10. Update any organization transfers ###
        Rails.logger.info "STEP 10. Update any organization transfers"

        if org_data_manager.present?
          # We already have org work media IDs, let's check for org coll media IDs in case this is a re-run
          org_coll_media_ids = ActiveFedora::SolrService.query(
            "has_model_ssim:Media && media_organization_id_ssim:#{organization_collection.id}", rows: 999999, fl: ["id"]
          ).map { |doc| doc['id'] }
          org_work_coll_media_ids = (org_media_ids + org_coll_media_ids).compact.uniq
          # Find org transfers for media associated with org where receiving user is legacy data manager and is org transfer
          org_transfers = ProxyDepositRequest.where(work_id: org_work_coll_media_ids, receiving_user_id: org_data_manager.id, organization_transfer: true)
          org_transfers.each do |transfer|
            # Update without saving due to not wanting to send messages
            transfer.update_column :receiving_user_id, organization_collection.id
            transfer.update_column :receiving_user_type, "OrganizationCollection"
          end
        end

        ### STEP 11. Reindex all media associated with org team, devices, and objects ###
        Rails.logger.info "STEP 11. Reindex all media associated with org team, devices, and objects"

        Rails.logger.info "Reindexing media to catch changes from objects, devices, and/or org team/project"
        all_media_ids.compact.uniq.sort.each { |id| SaveWorkJob.set( queue: Hyrax.config.update_slow_queue_name ).perform_later(id) }

        # Reindex objects one more time (yes, duplicate reindex) to catch changes in media
        # Objects index team membership from media, so only needed if org team/project exists
        if organization_team.present?
          wait_until_no_jobs("SaveWorkJob")
          Rails.logger.info "Reindexing objects to capture media collection membership changes"
          biological_specimen_ids.compact.uniq.each { |id| SaveWorkJob.set( queue: Hyrax.config.update_slow_queue_name ).perform_later(id) }
          cultural_heritage_object_ids.compact.uniq.each { |id| SaveWorkJob.set( queue: Hyrax.config.update_slow_queue_name ).perform_later(id) }
        end

        ### STEP 12. Reindex any sequential section lists linked to organization ###
        Rails.logger.info "STEP 12. Reindex any sequential section lists linked to organization"

        ActiveFedora::SolrService.query(
            "has_model_ssim:SequentialSectionList && organization_id_ssim:#{organization_work.id}", rows: 999999, fl: ["id"]
        ).each { |list_doc| SaveWorkJob.set( queue: Hyrax.config.update_slow_queue_name ).perform_later(list_doc["id"]) }

        Rails.logger.info "--- MIGRATION PHASE 1 COMPLETE, LEGACY ORGANIZATION #{organization_work_id} HAS BEEN COPIED TO ORGANIZATION COLLECTION #{organization_collection.id} ---"
        Rails.logger.info "--- WAIT FOR DOCUMENT REINDEXING BEFORE PROCEEDING TO PHASE 2 ---"
      end

      # If org work has been migrated to org collection and org work still exists and must be deleted
      def is_migrated?
        if !organization_work.present? || !organization_collection.present?
          raise "FAILED. Either organization work or organization collection not present!"
        end

        ### STEP 1. Has organization metadata been copied? ###
        Rails.logger.info "STEP 1. Has organization metadata been copied?"

        copied_metadata = organization_metadata.except(:date_managed)
        if !copied_metadata.all? { |field, value| organization_collection.send(field) == value }
          raise "STEP 1 FAILED. Metadata not validated."
        end
        if organization_collection.managed_by_non_admin? &&
            organization_work.date_managed.present? &&
            organization_collection.date_managed != organization_work.date_managed
          raise "STEP 1 FAILED. Management date not validated."
        end
        if !organization_collection.managed_by_non_admin? && organization_collection.date_managed.present?
          raise "STEP 1 FAILED. Management date not validated."
        end

        ### STEP 2. Have all media, devices, and objects been removed from organization work? ###
        Rails.logger.info "STEP 2. Have all media, devices, and objects been removed from organization work?"

        if (
          organization_work.media.present? ||
          organization_work.device_media.present? ||
          organization_work.physical_objects.present? ||
          organization_work.devices.present?
        )
          raise "STEP 2 FAILED. Organization work retains contents."
        end

        ### STEP 3. Have all team sub-projects been removed from the organization team? ###
        Rails.logger.info "STEP 3. Have all non-org team media, objects, and sub-projects been removed from the organization team?"

        if organization_team.present?
          if Collection.where("member_of_collection_ids_ssim:#{organization_team.id}").present?
            raise "STEP 3 FAILED. Organization team still retains child projects."
          end

          legacy_organization_team_media_docs = ActiveFedora::SolrService.query(
            "member_of_collection_ids_ssim:#{organization_team.id} AND media_organization_id_ssim:#{organization_work.id}",
            rows: 999999
          )
          non_organization_team_media_docs = ActiveFedora::SolrService.query(
            "member_of_collection_ids_ssim:#{organization_team.id} AND -media_organization_id_ssim:#{organization_collection.id}",
            rows: 999999
          )

          if legacy_organization_team_media_docs.present? || non_organization_team_media_docs.present?
            raise "STEP 3 FAILED. Organization team still retains media."
          end
        end

        ### STEP 4. Have members from organizatiom team been copied? ###
        Rails.logger.info "STEP 4. Have members from organizatiom team been copied?"

        org_data_manager = nil
        if organization_team.present?
          conditions = []

          # If data manager present, has been added to org collection as manager? ###
          if organization_work&.data_manager&.first.present?
            org_data_manager = User.find_by_user_key(organization_work&.data_manager&.first)
            conditions << (organization_collection.managers.include?(org_data_manager))
          end

          # What about other team users?
          roles = [:managers, :editors, :depositors, :downloaders, :viewers]
          roles.each do |role|
            (organization_team.send(role) || []).each do |user|
              next if ( user.id.present? && (user.id == org_data_manager&.id) )
              conditions << (organization_collection.send(role).include?(user))
            end
          end

          if !conditions.all?
            raise "STEP 4 FAILED. Some organization team members not copied."
          end

          # Destroy user groups now so we can check that these are gone before completing migration
          organization_team.user_groups.compact.each(&:destroy!) if organization_team.user_groups.compact.present?

          if organization_team.user_groups.compact.present? # this should be [nil, nil, ...]
            raise "STEP 4 FAILED. Organization team user groups present."
          end
        end

        ### STEP 5. Has automated media transfer been enabled if necessary? ###
        Rails.logger.info "STEP 5. Has automated media transfer been enabled if necessary?"

        if org_data_manager.present? && !organization_collection.media_ownership_transfer
          raise "STEP 5 FAILED. Organization work had data manager but media transfer not enabled for collection."
        elsif organization_collection.media_ownership_transfer && !org_data_manager.present?
          raise "STEP 5 FAILED. Organization work did not have data manager but media transfer is enabled for collection."
        end

        ### STEP 6. Does data manager user still retain ownership of organization media? ###
        Rails.logger.info "STEP 6. Does data manager user still retain ownership of organization media?"

        if (
          org_data_manager.present? &&
          Media.where("media_organization_id_ssim": organization_work.id, "user_with_ownership_ssi": org_data_manager.user_key).count > 0
        )
          raise "STEP 6 FAILED. Data manager user retains ownership of organization media."
        end

        ### STEP 7. Do any organization transfers exist naming data manager as the receiving user? ###
        Rails.logger.info "STEP 7. Do any organization transfers exist naming data manager as the receiving user?"

        org_media_ids = ActiveFedora::SolrService.query(
          "has_model_ssim:Media && media_organization_id_ssim:#{organization_collection.id}", rows: 999999, fl: ["id"]
        ).map { |doc| doc['id'] }

        if (
          org_data_manager.present? &&
          org_media_ids.present? &&
          ProxyDepositRequest.where(work_id: org_media_ids, receiving_user_id: org_data_manager.id, organization_transfer: true).count > 0
        )
          raise "STEP 7 FAILED. Data manager user is still named on organization transfer requests."
        end

        ### STEP 8. Do any sequential section lists still reference organization work? ###
        Rails.logger.info "STEP 8. Do any sequential section lists still reference organization work?"

        if ActiveFedora::SolrService.count("has_model_ssim:SequentialSectionList && organization_id_ssim:#{organization_work.id}") > 0
          raise "STEP 8 FAILED. Sequential section lists exist that reference organization work."
        end

        ### STEP 9. Have org team branding files and associated files been copied to the org collection?
        Rails.logger.info "STEP 9. Does the organization team still have any associated files or attachment files?"

        if organization_team.present?
          # representative ID (thumbnail on form)
          if organization_team.representative_id.present? && (organization_collection.representative_id != organization_team.representative_id)
            raise "STEP 9 FAILED. Issue with copying organization representative ID."
          end

          # thumbnail ID
          if organization_team.thumbnail_id.present? && (organization_collection.thumbnail_id != organization_team.thumbnail_id)
            raise "STEP 9 FAILED. Issue with copying organization thumbnail ID."
          end

          if (
            CollectionBrandingInfo.where(collection_id: organization_team.id).count > 0 ||
            (organization_work.agreement_attachment_url.present? && !organization_collection.agreement_attachment_url.present?)
          )
            raise "STEP 9 FAILED. Branding file or agreement attachment not copied to organization collection."
          end
        end

        ### STEP 10. Are all are all team roles and access grants destroyed?
        Rails.logger.info "STEP 10. Are all are all team roles and access grants destroyed?"
        # any media with remaining team access grants need to have those grants removed
        if organization_team.present?
          team_access_media = SolrDocument.where("has_model_ssim:Media AND
                                                  read_access_group_ssim:#{organization_team.id}_* OR
                                                  download_access_group_ssim:#{organization_team.id}_* OR
                                                  edit_access_group_ssim:#{organization_team.id}_*")
          if team_access_media.present?
            raise "STEP 10 FAILED. Found #{team_access_media.count} media with team access grants."
          end
        end

        Rails.logger.info "---"
        Rails.logger.info "Validation successful!"
        Rails.logger.info "---"

        return true
      end

      # Complete migration by deleting legacy org work and org team
      def complete_migration
        if is_migrated?
          Rails.logger.info "STEP 11. Delete organization work."

          begin
            if organization_team.present?
              organization_team.destroy!
            end

            if organization_work.present?
              Organization.find(organization_work_id).destroy! # using destroy directly causes UnmutableParentError
            end
          rescue ArgumentError => e
            puts(e.backtrace)
            Rails.logger.warn "Raised ActiveTriples::ParentStrategy::UnmutableParentError on organization destruction, ignoring"
          end

          Rails.logger.info "FINISHED STEP 11. Delete organization work."
        end
      end

      # @!endgroup

      # @!group Utility

      def wait_until_no_jobs(job_class)
        sleep(10) until !active_jobs(job_class).present?
      end

      def batch_user
        @batch_user ||= User.batch_user
      end

      # @!endgroup
    end
  end
end
