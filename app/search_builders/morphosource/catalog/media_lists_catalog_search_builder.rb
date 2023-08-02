class Morphosource::Catalog::MediaListsCatalogSearchBuilder < Hyrax::CatalogSearchBuilder

  private

    def models
      [::MediaList, ::SequentialSectionList]
    end
end
