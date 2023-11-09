module Morphosource
  class CatalogSearchBuilder < Hyrax::CatalogSearchBuilder
    # enable f.field facet format
    include Morphosource::Facets::SearchBuilderFacetParamsBehavior 
  end
end