class Morphosource::Catalog::MediaCatalogSearchBuilder < Hyrax::CatalogSearchBuilder
  # override filter_collection_facet_for_access
  include Morphosource::Facets::CollectionsSearchBuilderBehavior

  private

    def models
      [::Media]
    end
end
