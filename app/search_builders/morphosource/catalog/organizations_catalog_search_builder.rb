class Morphosource::Catalog::OrganizationsCatalogSearchBuilder < Hyrax::CatalogSearchBuilder

  private

    def models
      byebug
      [::Organization, ::OrganizationCollection]
    end
end
