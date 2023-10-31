module Morphosource
  module Collections
    module OrganizationCollections
      module PhysicalObjects
        class CulturalHeritageObjectsController < Morphosource::Collections::CulturalHeritageObjectsController

          # temporary restriction so only admins can access organizations
          # before_action :authorize_admin

          def media_objects_search_builder_class
            Morphosource::Collections::OrganizationCollections::MediaObjectsSearchBuilder
          end

        end
      end
    end
  end
end