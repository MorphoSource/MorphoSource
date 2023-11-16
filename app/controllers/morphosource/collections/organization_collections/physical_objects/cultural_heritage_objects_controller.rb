module Morphosource
  module Collections
    module OrganizationCollections
      module PhysicalObjects
        class CulturalHeritageObjectsController < Morphosource::Collections::CulturalHeritageObjectsController

          include Morphosource::Collections::OrganizationCollectionsControllerBehavior

          # restrict to admins
          # before_action :authorize_admin

        end
      end
    end
  end
end