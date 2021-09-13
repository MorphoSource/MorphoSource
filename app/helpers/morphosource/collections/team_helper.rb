module Morphosource
  module Collections
    module TeamHelper
      include Morphosource::CollectionHelper
      include Blacklight::RenderConstraintsHelperBehavior

      
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
