# Retrieves all physical objects a user has edit access to
module Morphosource
  module Users
    class EditObjectsSearchBuilder < Hyrax::WorksSearchBuilder

      include Hyrax::My::SearchBuilderBehavior

      def models
        [BiologicalSpecimen, CulturalHeritageObject]
      end

      def discovery_permissions
        ["edit"]
      end

    end
  end
end
