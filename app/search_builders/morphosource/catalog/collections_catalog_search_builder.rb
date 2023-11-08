class Morphosource::Catalog::CollectionsCatalogSearchBuilder < Morphosource::CatalogSearchBuilder

  private

    def models
      [::Collection]
    end
end
