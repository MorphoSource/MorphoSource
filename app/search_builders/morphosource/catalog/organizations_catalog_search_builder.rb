class Morphosource::Catalog::OrganizationsCatalogSearchBuilder < Hyrax::CatalogSearchBuilder

  private

    def models
      [::Organization]
    end
end
