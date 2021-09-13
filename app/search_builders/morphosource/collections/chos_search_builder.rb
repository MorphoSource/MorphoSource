# Retrieves all specimens associated with media for which a user has edit access or has been granted read access
module Morphosource
  module Collections
    class ChosSearchBuilder < Morphosource::Collections::ObjectsSearchBuilder
      include Hyrax::FilterByType

      def models
        [CulturalHeritageObject]
      end

    end
  end
end
