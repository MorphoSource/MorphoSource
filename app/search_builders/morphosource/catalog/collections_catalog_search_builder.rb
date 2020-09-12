class Morphosource::Catalog::CollectionsCatalogSearchBuilder < Hyrax::CatalogSearchBuilder

  private

    def models
      [::Collection]
    end
end
