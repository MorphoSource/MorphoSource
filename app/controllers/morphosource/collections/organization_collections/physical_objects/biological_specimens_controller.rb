module Morphosource
  module Collections
    module OrganizationCollections
      module PhysicalObjects
        class BiologicalSpecimensController < Morphosource::Collections::BiologicalSpecimensController

          def media_objects_search_builder_class
            Morphosource::Collections::OrganizationCollections::MediaObjectsSearchBuilder
          end

        end
      end
    end
  end
end