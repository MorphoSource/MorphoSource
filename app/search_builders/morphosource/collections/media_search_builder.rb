module Morphosource
  module Collections
    class MediaSearchBuilder < Hyrax::CollectionMemberSearchBuilder
      # override filter_collection_facet_for_access
      include Morphosource::Facets::CollectionsSearchBuilderBehavior

      self.default_processor_chain += [:return_selected_fields, :filter_collection_facet_for_access]

      def member_of_collection(solr_parameters)
        solr_parameters[:fq] ||= []
        if collection.organization.present?
          solr_parameters[:fq] << "(#{collection_membership_field}:(#{collection_ids.join(' OR ')}) OR media_organization_id_ssim:#{collection.organization&.id})"
        else
          solr_parameters[:fq] << "(#{collection_membership_field}:(#{collection_ids.join(' OR ')}))"
        end
      end

      def return_selected_fields(solr_parameters)
        solr_parameters[:fl] = 'id,has_model_ssim,title_tesim,thumbnail_path_ss,part_tesim,physical_object_title_ssim,taxonomy_ssim,human_readable_media_type_tesim,date_uploaded_dtsi,fileset_accessibility_ssim'
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
