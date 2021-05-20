# Retrieves all specimens associated with media for which a user has edit access or has been granted read access
module Morphosource
  module Users
    class MySpecimensSearchBuilder < MyObjectsSearchBuilder

      def models
        [BiologicalSpecimen]
      end

    end
  end
end
