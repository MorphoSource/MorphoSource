module Morphosource
  module Collections
    module OrganizationCollections
      class MediaSearchBuilder < Morphosource::Collections::MediaSearchBuilder

        def member_of_collection(solr_parameters)
          solr_parameters[:fq] ||= []
          solr_parameters[:fq] << "(member_of_collection_ids_ssim:#{collection.id} OR media_organization_id_ssim:#{collection.id})"
        end

        # organization members can view all organization media
        # other users can view media they have permission to view
        def add_access_controls_to_solr_params(solr_parameters)
          solr_parameters[:fq] ||= []
          unless user_is_organization_member?
            solr_parameters[:fq] << gated_discovery_filters.reject(&:blank?).join(' OR ')
          end
          byebug
          Rails.logger.debug("Solr parameters: #{solr_parameters.inspect}")
        end

        private

          def user_is_organization_member?
            return false unless current_user

            (@collection.user_groups.map(&:name) & current_user.groups).present?
          end

      end
    end
  end
end
