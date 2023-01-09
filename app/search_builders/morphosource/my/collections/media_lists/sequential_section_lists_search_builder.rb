module Morphosource
  module My
    module Collections
      module MediaLists
        class SequentialSectionListsSearchBuilder < Morphosource::My::Collections::MediaListsSearchBuilder

          def models
            [::Collection, SequentialSectionList]
          end

          def collection_types
            [Hyrax::CollectionType.find_by(title: "Sequential Section List")]
          end

        end
      end
    end
  end
end