# Retrieves all physical objects a user has edit access to
module Morphosource
  module Users
    class EditSpecimensSearchBuilder < EditObjectsSearchBuilder

      def models
        [BiologicalSpecimen]
      end

    end
  end
end
