class Morphosource::Catalog::ObjectsCatalogSearchBuilder < Hyrax::CatalogSearchBuilder
  # override filter_collection_facet_for_access
  include Morphosource::Facets::CollectionsSearchBuilderBehavior

  private

    def models
      [::BiologicalSpecimen, ::CulturalHeritageObject]
    end

end
