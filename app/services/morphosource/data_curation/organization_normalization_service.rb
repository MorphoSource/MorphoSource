module Morphosource
  module DataCuration
    class OrganizationNormalizationService

      def self.call(team_id: nil, collection_id: nil, old_manager_email: nil, email: nil, remove_previous_reviewers: false, update_publication_status: nil)
        new(team_id: team_id,
            collection_id: collection_id,
            old_manager_email: old_manager_email,
            email: email,
            remove_previous_reviewers: remove_previous_reviewers,
            update_publication_status: update_publication_status
        ).call
      end

      def initialize(team_id: nil, collection_id: nil, old_manager_email: nil, email: nil, remove_previous_reviewers: false, update_publication_status: nil)
        begin
          # verify all objects exist
          @team = Collection.find(team_id)
          @organization = @team.organization
          @user_email = User.find_by(email: email).email
          @remove_previous_reviewers = remove_previous_reviewers
          @update_publication_status = update_publication_status
          if collection_id.blank? && old_manager_email.blank?
            raise "one or both of media collection id or old manager email required"
          elsif collection_id.blank?
            @old_manager = User.find_by(email: old_manager_email)
          elsif old_manager_email.blank?
            @collection_id = Collection.find(collection_id).id
          else
            @old_manager = User.find_by(email: old_manager_email)
            @collection_id = Collection.find(collection_id).id
          end
        rescue
          raise "One or more required parameters is not present or incorrect"
        end
      end

      def call
        update_media(media_ids)
      end

      private

        def media_ids
          if !@old_manager.present?
            Morphosource::SolrService.new.get_docs("media_organization_id_ssim:#{@organization.id} AND member_of_collection_ids_ssim:#{@collection_id}", fl:"id").map{|m| m["id"]}
          elsif !@collection_id.present?
            Morphosource::SolrService.new.get_docs("media_organization_id_ssim:#{@organization.id} AND user_with_ownership_ssi:#{@old_manager.ms_id}", fl:"id").map{|m| m["id"]}
          else
            Morphosource::SolrService.new.get_docs("media_organization_id_ssim:#{@organization.id} AND member_of_collection_ids_ssim:#{@collection_id} AND user_with_ownership_ssi:#{@old_manager.ms_id}", fl:"id").map{|m| m["id"]}
          end
        end

        def update_media(media_ids)
          media_ids.each do |id|
            OrganizationNormalizationJob.perform_later(media_id: id, organization_id: @organization.id, user_email: @user_email, remove_previous_reviewers: @remove_previous_reviewers, update_publication_status: @update_publication_status)
          end
        end
    end
  end
end
