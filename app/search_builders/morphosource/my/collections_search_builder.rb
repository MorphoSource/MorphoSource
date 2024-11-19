module Morphosource
  module My
    class CollectionsSearchBuilder < Hyrax::Dashboard::CollectionsSearchBuilder
      include Hyrax::Dashboard::ManagedSearchFilters
      # enable f.field facet format
      include Morphosource::Facets::SearchBuilderFacetParamsBehavior

      self.solr_access_filters_logic += [:apply_collection_download_permissions]
      self.default_processor_chain += [:filter_collections]

      # This overrides the models in FilterByType
      def models
        [::Collection, ::OrganizationCollection, ::MediaList, ::SequentialSectionList]
      end

      # override to restrict to specific collection type
      def collection_types
        Hyrax::CollectionType.all
      end

      # Add queries that excludes everything except for specific collection types
      def filter_collections(solr_parameters)
        solr_parameters[:fq] ||= []
        solr_parameters[:fq] << "{!terms f=collection_type_gid_ssim}#{collection_types_to_solr_clause}"
      end

      def apply_collection_download_permissions(_permission_types, _ability = current_ability)
        collection_ids = collection_ids_for_download
        return [] if collection_ids.empty?
        ["{!terms f=id}#{collection_ids.join(',')}"]
      end

      private

        def collection_types_to_solr_clause
          collection_types.map do |type|
            type.to_global_id
          end.join(',')
        end


        def collection_ids_for_download
          Hyrax::Collections::PermissionsService.collection_ids_for_download_works(ability: current_ability)
        end

    end
  end
end