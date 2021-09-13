module Morphosource
  module Collections
    class MediaSearchBuilder < Hyrax::CollectionMemberSearchBuilder

      def member_of_collection(solr_parameters)
        solr_parameters[:fq] ||= []
        if collection.organization.present?
          solr_parameters[:fq] << "(#{collection_membership_field}:(#{collection_ids.join(' OR ')}) OR media_organization_id_ssim:#{collection.organization&.id})"
        else
          solr_parameters[:fq] << "(#{collection_membership_field}:(#{collection_ids.join(' OR ')}))"
        end
      end

      def models
        [Media]
      end

      def collection_ids
        [collection.id] + subcollection_ids
      end

      def subcollection_ids
        return [] unless collection.team?

        subcollections = Morphosource::Collections::CollectionMemberService.new(scope: scope, collection: collection, params: {}).available_member_subcollections
        subcollections.docs.map(&:id)
      end

    end
  end
end
