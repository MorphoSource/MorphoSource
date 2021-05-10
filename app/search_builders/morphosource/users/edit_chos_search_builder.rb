# Retrieves all physical objects a user has edit access to
module Morphosource
  module Users
    class EditChosSearchBuilder < EditObjectsSearchBuilder

      def models
        [CulturalHeritageObject]
      end

    end
  end
end
