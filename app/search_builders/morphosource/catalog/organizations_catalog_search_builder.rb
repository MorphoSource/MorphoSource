class Morphosource::Catalog::OrganizationsCatalogSearchBuilder < Morphosource::CatalogSearchBuilder

  private

    def models
      [::Organization, ::OrganizationCollection]
    end
end
