module Morphosource
  module Dashboard
    module Collections
      class ProjectsController < Morphosource::Dashboard::CollectionsController

        skip_load_and_authorize_resource only: [:edit, :update, :new, :members], instance_name: :collection

        before_action :redirect_to_collection_type, only: []
        before_action :build_breadcrumbs, only: []
        before_action :load_collection

        self.presenter_class = Morphosource::Collections::ProjectPresenter

        private

          def default_collection_type
            Hyrax::CollectionType.find_by(title: "Project")
          end

      end
    end
  end
end
