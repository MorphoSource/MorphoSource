class Morphosource::Catalog::MediaCatalogSearchBuilder < Hyrax::CatalogSearchBuilder
  # override filter_collection_facet_for_access
  include Morphosource::Facets::CollectionsSearchBuilderBehavior

  include Morphosource::OrganizationalAccessBehavior

  # TODO: At some point, :add_access_controls_to_solr_params is getting added to the default_processor_chain
  self.default_processor_chain = self.default_processor_chain.uniq

  private

    def models
      [::Media]
    end
end
