module Morphosource
  module Dashboard
    module Collections
      class ProjectsController < Morphosource::Dashboard::CollectionsController

        skip_load_and_authorize_resource only: [:edit, :update, :new, :members], instance_name: :collection

        before_action :redirect_to_collection_type, only: []

        self.presenter_class = Morphosource::Collections::ProjectPresenter

        def create_list
          byebug
          redirect_to project_edit_path(@collection)
        end

        private

          def collection_type
            Hyrax::CollectionType.find_by(title: "Project")
          end
          alias :default_collection_type :collection_type

      end
    end
  end
end
