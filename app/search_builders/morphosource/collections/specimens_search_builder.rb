# Retrieves all specimens associated with media for which a user has edit access or has been granted read access
module Morphosource
  module Collections
    class SpecimensSearchBuilder < Morphosource::Collections::ObjectsSearchBuilder
      include Hyrax::FilterByType

      def models
        [BiologicalSpecimen]
      end

    end
  end
end
