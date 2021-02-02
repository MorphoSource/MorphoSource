module Morphosource
  class CollectionMemberSearchBuilderNoFacetLimits < ::Hyrax::CollectionMemberSearchBuilder
    self.default_processor_chain += [:no_facet_limit]

    def no_facet_limit(solr_parameters)
      solr_parameters["facet.limit"] = -1
    end
  end
end