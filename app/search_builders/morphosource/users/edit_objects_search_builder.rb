# Retrieves all physical objects a user has edit access to
module Morphosource
  module Users
    class EditObjectsSearchBuilder < Hyrax::WorksSearchBuilder
      include Morphosource::SearchBuilderBehavior
      include Hyrax::My::SearchBuilderBehavior
      # enable f.field facet format
      include Morphosource::Facets::SearchBuilderFacetParamsBehavior

      def models
        [BiologicalSpecimen, CulturalHeritageObject]
      end

      def discovery_permissions
        ["edit"]
      end

    end
  end
end
