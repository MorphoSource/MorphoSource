module Morphosource
  module Collections
    module OrganizationCollections
      module PhysicalObjects
        class BiologicalSpecimensController < Morphosource::Collections::BiologicalSpecimensController

          include Morphosource::Collections::OrganizationCollectionsControllerBehavior

          # restrict to admins
          # before_action :authorize_admin

        end
      end
    end
  end
end