module Morphosource
  class CatalogSearchBuilder < Hyrax::CatalogSearchBuilder
    # enable f.field facet format
    include Morphosource::Facets::SearchBuilderFacetParamsBehavior 

    def add_facet_paging_to_solr(solr_params)
      super
  
      return unless facet.present?
      facet_config = blacklight_config.facet_fields[facet]
      contains = blacklight_params[request_keys[:contains]]
      if blacklight_params[request_keys[:contains]]
        solr_params[:"f.#{facet_config.field}.facet.contains"] = contains
        solr_params[:"f.#{facet_config.field}.facet.contains.ignoreCase"] = true
      end
    end
  end
end