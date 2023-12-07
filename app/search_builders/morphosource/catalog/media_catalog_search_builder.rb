class Morphosource::Catalog::MediaCatalogSearchBuilder < Morphosource::CatalogSearchBuilder
  # override filter_collection_facet_for_access
  include Morphosource::Facets::CollectionsSearchBuilderBehavior
  # organization collection members can access that organization's media
  include Morphosource::OrganizationalAccessBehavior

  private

    def models
      [::Media]
    end
end
