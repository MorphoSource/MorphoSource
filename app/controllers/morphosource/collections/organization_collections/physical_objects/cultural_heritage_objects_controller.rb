module Morphosource
  module Collections
    module OrganizationCollections
      module PhysicalObjects
        class CulturalHeritageObjectsController < Morphosource::Collections::CulturalHeritageObjectsController

          include Morphosource::Collections::OrganizationCollectionsControllerBehavior

          skip_load_and_authorize_resource only: [:show, :about, :facet, :objects_export], instance_name: :collection

          # restrict to admins
          # before_action :authorize_admin

          def media_count_search_builder_class
            Morphosource::Collections::OrganizationCollections::OrganizationMediaSearchBuilder
          end

          self.presenter_class = Morphosource::Collections::OrganizationPresenter

        end
      end
    end
  end
end