module Morphosource
  class CatalogSearchBuilder < Hyrax::CatalogSearchBuilder
    # enable f.field facet format
    include Morphosource::Facets::SearchBuilderFacetParamsBehavior 

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

    private

    # from https://github.com/samvera/hyrax/blob/main/app/search_builders/hyrax/catalog_search_builder.rb
    # original contains a join statement to search work and members which slows down solr queries a ton
    # the {!lucene} gives us the OR syntax
    def new_query
      "{!lucene}#{interal_query(dismax_query)}"
    end
  end
end