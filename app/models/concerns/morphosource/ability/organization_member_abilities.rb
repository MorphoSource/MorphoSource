module Morphosource
  module Ability
    module OrganizationMemberAbilities

      # View Media and FileSets through organization membership
      def organization_member_abilities

        can :read, ::Media do |obj|
          has_organizational_access_to_media? obj
        end

        can :edit, ::Media do |obj|
          has_organizational_edit_access_to_media? obj
        end

        can :read, ::FileSet do |obj|
          has_organizational_access_to_fileset? obj
        end

        can :edit, ::FileSet do |obj|
          has_organizational_edit_access_to_fileset? obj
        end

        can :read, ::SolrDocument do |obj|
          case obj.has_model&.first
          when 'Media'
            has_organizational_access_to_media? obj
          when 'FileSet'
            has_organizational_access_to_fileset? obj
          else
            false
          end
        end

        can :edit, ::SolrDocument do |obj|
          case obj.has_model&.first
          when 'Media'
            has_organizational_edit_access_to_media? obj
          when 'FileSet'
            has_organizational_edit_access_to_fileset? obj
          else
            false
          end
        end

        can :read, String do |id|
          obj = SolrDocument.find(id)
          can? :read, obj
        rescue
          false
        end

        can :edit, String do |id|
          obj = SolrDocument.find(id)
          can? :edit, obj
        rescue
          false
        end

        # Proxy Deposits

        can :transfer, String do |id|
          admin? || user_is_media_organization_manager?(id)
        end

        can :accept, ProxyDepositRequest do |request|
          unless request.status == "pending"
            false
          else
            user_is_media_organization_manager?(request.work_id)
          end
        end

        can :reject, ProxyDepositRequest do |request|
          unless request.status == "pending"
            false
          else
            user_is_media_organization_manager?(request.work_id)
          end
        end
      end

      private

        # Users who are members of the organizations whose IDs are stored in these media fields can view the media
        def organization_fields
          ["media_organization_id_ssim","media_device_facility_organization_id_ssim"]
        end

        def has_organizational_access_to_media?(media)
          Rails.logger.debug("[CANCAN] Checking for individual media access through organization membership")
          return false unless media = solr_document(media)

          (organization_groups(media) & @user_groups).present?
        end

        def has_organizational_edit_access_to_media?(media)
          Rails.logger.debug("[CANCAN] Checking for individual media edit access through organization membership")
          return false unless media = solr_document(media)
          (organization_edit_groups(media) & @user_groups).present?
        end

        def has_organizational_access_to_fileset?(file_set)
          Rails.logger.debug("[CANCAN] Checking for individual file set access through organization membership")
          return false unless file_set = solr_document(file_set)

          return false unless media_id = Morphosource::SolrService.new.get_docs("file_set_ids_ssim:#{file_set.id}").first&.dig("id")

          has_organizational_access_to_media?(media_id)
        end

        def has_organizational_edit_access_to_fileset?(file_set)
          Rails.logger.debug("[CANCAN] Checking for individual file set edit access through organization membership")
          return false unless file_set = solr_document(file_set)

          return false unless media_id = Morphosource::SolrService.new.get_docs("file_set_ids_ssim:#{file_set.id}").first&.dig("id")

          has_organizational_edit_access_to_media?(media_id)
        end

        def organization_groups(media)
          return [] unless document = solr_document(media)

          organization_fields.each_with_object([]) do |field, groups|
            next unless org_id = document[field]&.first
            if OrganizationCollection.exists?(org_id)
              OrganizationCollection::DEFAULT_GROUP_ROLES.each {|role| groups << "#{document[field].first}_#{role}"}
            elsif Organization.exists?(org_id)
              if team_id = SolrDocument.find(org_id)['team_id_tesim']&.first
                Collection::DEFAULT_GROUP_ROLES.each {|role| groups << "#{team_id}_#{role}"}
              end
            end
          end
        end

        def organization_edit_groups(media)
          return [] unless document = solr_document(media)
          owner_id = media['owner_ssim']&.first
          return [] unless OrganizationCollection.exists?(owner_id)
          ['managers', 'editors'].each_with_object([]) {|role, groups| groups << "#{owner_id}_#{role}"}
        end


        def solr_document(obj)
          case obj
          when FileSet
            return SolrDocument.find(obj.id)
          when Media
            return SolrDocument.find(obj.id)
          when SolrDocument
            return obj
          when String
            return SolrDocument.find(obj)
          when Hash
            return SolrDocument.find(obj['id'])
          end
        rescue
          nil
        end

        def user_is_media_organization_manager?(document_id)
          owner_id = SolrDocument.find(document_id)['user_with_ownership_ssi']
          user_is_manager_of_organization?(owner_id)
        end

        def user_is_manager_of_organization?(id)
          current_user.groups.include? "#{id}_managers"
        end

    end
  end
end