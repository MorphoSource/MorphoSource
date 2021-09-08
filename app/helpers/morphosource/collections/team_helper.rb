module Morphosource
  module Collections
    module TeamHelper
      include Morphosource::CollectionHelper
      include Blacklight::RenderConstraintsHelperBehavior

      def remove_constraint_url(localized_params)
        scope = localized_params.delete(:route_set) || self

        unless localized_params.is_a? ActionController::Parameters
          localized_params = ActionController::Parameters.new(localized_params)
        end

        options = localized_params.merge(q: nil, action: 'index')
        options.permit!
        scope.url_for(options)
      end

      # provides longer versions of intersections facet values
      def intersections_values(value)
        if value == 'Team and Organization'
          "Media owned by team AND of organization physical objects"
        elsif value == 'Organization Only'
          "Media of organization physical objects NOT owned by team"
        elsif value == 'Team Only'
          "Media owned by team NOT of organization physical objects"
        elsif value == 'Team'
          "All media owned by team"
        elsif value == 'Organization'
          "All media of organization physical objects"
        end
      end

    end
  end
end
