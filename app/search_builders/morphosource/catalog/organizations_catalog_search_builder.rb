class Morphosource::Catalog::OrganizationsCatalogSearchBuilder < Hyrax::CatalogSearchBuilder

  private

    def models
      [::Organization, ::OrganizationCollection]
    end
end
