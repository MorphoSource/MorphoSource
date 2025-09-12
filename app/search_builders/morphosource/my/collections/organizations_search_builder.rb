module Morphosource
  module My
    module Collections
      class OrganizationsSearchBuilder < Morphosource::My::CollectionsSearchBuilder
        include Morphosource::SearchBuilderBehavior

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
          if search_state.params[:sort].present?
            solr_parameters[:sort] = search_state.params[:sort]
          else
            solr_parameters[:sort] = "#{sort_field} asc"
          end
        end

        def add_facet_paging_to_solr(solr_params)
        super

        return unless facet.present?
          facet_config = blacklight_config.facet_fields[facet]
          contains = blacklight_params[blacklight_config.facet_paginator_class.request_keys[:contains]]
          if blacklight_params[blacklight_config.facet_paginator_class.request_keys[:contains]]
            solr_params[:"f.#{facet_config.field}.facet.contains"] = contains
            solr_params[:"f.#{facet_config.field}.facet.contains.ignoreCase"] = true
          end
        end

      end
    end
  end
end