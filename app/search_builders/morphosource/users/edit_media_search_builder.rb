# retrieves all media a user has edit access to, either through a role (collection member group), or as an individual
module Morphosource
  module Users
    class EditMediaSearchBuilder < Hyrax::WorksSearchBuilder
      include Morphosource::SearchBuilderBehavior
      include Hyrax::My::SearchBuilderBehavior
      # enable f.field facet format
      include Morphosource::Facets::SearchBuilderFacetParamsBehavior

      def models
        [Media]
      end

      def discovery_permissions
        ["edit"]
      end
    end
  end
end
