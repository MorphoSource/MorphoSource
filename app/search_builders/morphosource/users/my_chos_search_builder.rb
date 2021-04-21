# Retrieves all cultural heritage objects associated with media for which a user has edit access or has been granted read access
module Morphosource
  module Users
    class MyChosSearchBuilder < MyObjectsSearchBuilder

      def models
        [CulturalHeritageObject]
      end

    end
  end
end
