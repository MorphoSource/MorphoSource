module Morphosource
  module DataCuration
    class OrganizationNormalizationService

      def self.call(team_id: nil, project_id: nil, old_manager_email: nil, email: nil, remove_previous_reviewers: false, update_publication_status: nil)
        new(team_id: team_id,
            project_id: project_id,
            old_manager_email: old_manager_email,
            email: email.downcase,
            remove_previous_reviewers: remove_previous_reviewers,
            update_publication_status: update_publication_status
        ).call
      end

      def initialize(team_id: nil, project_id: nil, old_manager_email: nil, email: nil, remove_previous_reviewers: false, update_publication_status: nil)
        begin
          # verify all objects exist
          @team = Collection.find(team_id) # organization-linked team or organization collection
          @organization = select_organization # organization work or organization collection
          @user_email = @team.team? ? User.find_by(email: email).email : nil # data manager email for org collections doesn't exist
          @remove_previous_reviewers = remove_previous_reviewers
          @update_publication_status = update_publication_status
          if project_id.blank? && old_manager_email.blank?
            raise "one or both of media collection id or old manager email required"
          elsif project_id.blank?
            @old_manager = User.find_by(email: old_manager_email)
          elsif old_manager_email.blank?
            @project_id = Collection.find(project_id).id
          else
            @old_manager = User.find_by(email: old_manager_email)
            @project_id = Collection.find(project_id).id
          end
        rescue
          raise "One or more required parameters is not present or incorrect"
        end
      end

      def call
        update_media(media_ids)
      end

      private

        def update_media(media_ids)
          media_ids.each do |id|
            OrganizationNormalizationJob.perform_later(media_id: id, organization_id: @organization.id, user_email: @user_email, remove_previous_reviewers: @remove_previous_reviewers, update_publication_status: @update_publication_status)
          end
        end

        def media_ids
          ids = media.map{ |m| m["id"] }
          if @team.team?
            data_manager_id = User.find_by(ms_id: @organization.data_manager.first)&.id
          elsif @team.organization_collection?
            data_manager_id = @team.id
          end
          # remove ids where transfer request has been generated
          ids.reject do |id|
            ProxyDepositRequest.where(work_id: id, organization_transfer: true, receiving_user_id: data_manager_id).present?
          end
        end

        def media
          if !@old_manager.present?
            organization_media_in_project
          elsif !@project_id.present?
            organization_media_with_old_manager
          else
            organization_media_in_project_with_old_manager
          end
        end

        def organization_media_in_project
          if @project_id == @organization.id
            Morphosource::SolrService.new.get_docs("media_organization_id_ssim:#{@organization.id} AND user_with_ownership_ssi:#{@organization.id} NOT organization_transfer_on_publish_bsi:true NOT pending_org_transfer_bsi:true", fl:"id")
          else
            Morphosource::SolrService.new.get_docs("media_organization_id_ssim:#{@organization.id} AND member_of_collection_ids_ssim:#{@project_id} NOT organization_transfer_on_publish_bsi:true NOT pending_org_transfer_bsi:true", fl:"id")
          end
        end

        def organization_media_with_old_manager
          Morphosource::SolrService.new.get_docs("media_organization_id_ssim:#{@organization.id} AND user_with_ownership_ssi:#{@old_manager.ms_id} NOT organization_transfer_on_publish_bsi:true NOT pending_org_transfer_bsi:true", fl:"id")
        end

        def organization_media_in_project_with_old_manager
          Morphosource::SolrService.new.get_docs("media_organization_id_ssim:#{@organization.id} AND member_of_collection_ids_ssim:#{@project_id} AND user_with_ownership_ssi:#{@old_manager.ms_id} NOT organization_transfer_on_publish_bsi:true NOT pending_org_transfer_bsi:true", fl:"id")
        end

        def select_organization
          if @team.team?
            @team.organization
          else
            @team
          end
        end

    end
  end
end
