class Morphosource::Catalog::MediaListsCatalogSearchBuilder < Morphosource::CatalogSearchBuilder

  private

    def models
      [::MediaList, ::SequentialSectionList]
    end
end
