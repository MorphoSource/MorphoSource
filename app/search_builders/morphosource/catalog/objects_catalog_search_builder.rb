class Morphosource::Catalog::ObjectsCatalogSearchBuilder < Hyrax::CatalogSearchBuilder

  private

    def models
      [::BiologicalSpecimen, ::CulturalHeritageObject]
    end
end
