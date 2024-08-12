module Morphosource
  module Collections
    module OrganizationCollections
      module PhysicalObjects
        class BiologicalSpecimensController < Morphosource::Collections::BiologicalSpecimensController

          include Morphosource::Collections::OrganizationCollectionsControllerBehavior

          helper_method :search_action_for_dashboard

          skip_load_and_authorize_resource only: [:show, :about, :facet, :objects_export], instance_name: :collection

          def media_count_search_builder_class
            Morphosource::Collections::OrganizationCollections::OrganizationMediaSearchBuilder
          end

          self.presenter_class = Morphosource::Collections::OrganizationPresenter

          def search_action_for_dashboard
            main_app.organization_specimens_path(@collection)
          end

        end
      end
    end
  end
end