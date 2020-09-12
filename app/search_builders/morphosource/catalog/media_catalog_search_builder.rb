class Morphosource::Catalog::MediaCatalogSearchBuilder < Hyrax::CatalogSearchBuilder

  private

    def models
      [::Media]
    end
end
