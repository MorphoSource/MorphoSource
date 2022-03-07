module Morphosource
  module DataCuration
    class OrganizationNormalizationService

      def self.call(team_id: nil, collection_id: nil, email: nil, update_publication_status: nil)
        new(team_id: team_id,
            collection_id: collection_id,
            email: email,
            update_publication_status: update_publication_status
        ).call
      end

      def initialize(team_id: nil, collection_id: nil, email: nil, update_publication_status: nil)
        begin
          # verify all objects exist
          @team = Collection.find(team_id)
          @organization = @team.organization
          @collection_id = Collection.find(collection_id).id
          @user_email = User.find_by(email: email).email
          @update_publication_status = update_publication_status
        rescue
          raise "One or more required parameters is not present or incorrect"
        end
      end

      def call
        update_media(media_ids)
      end

      private

        def media_ids
          Morphosource::SolrService.new.get_docs("media_organization_id_ssim:#{@organization.id} AND member_of_collection_ids_ssim:#{@collection_id}", fl:"id").map{|m| m["id"]}
        end

        def update_media(media_ids)
          media_ids.each do |id|
            OrganizationNormalizationJob.perform_later(media_id: id, organization_id: @organization.id, user_email: @user_email, update_publication_status: @update_publication_status)
          end
        end
    end
  end
end
