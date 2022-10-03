module Morphosource
  module My
    module Collections
      class MediaListsSearchBuilder < Morphosource::My::CollectionsSearchBuilder

        # This overrides the models in FilterByType
        def collection_types
          [Hyrax::CollectionType.find_by(title: "Media List")]
        end

      end
    end
  end
end