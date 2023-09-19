module Morphosource
  module My
    module Collections
      class OrganizationsSearchBuilder < Morphosource::My::CollectionsSearchBuilder

        self.solr_access_filters_logic -= [:apply_collection_download_permissions]
        self.default_processor_chain -= [:show_only_managed_collections_for_non_admins]

        def models
          [OrganizationCollection]
        end

        # This overrides the models in FilterByType
        def collection_types
          [Hyrax::CollectionType.find_by(title: "Organization")]
        end

        # Sort results by title if no query was supplied.
        # This overrides the default 'relevance' sort.
        def add_sorting_to_solr(solr_parameters)
          return if solr_parameters[:q]
          solr_parameters[:sort] ||= sort
          solr_parameters[:sort] ||= "#{sort_field} asc"
        end

      end
    end
  end
end