module Morphosource
  module Dashboard
    module Collections
      class ProjectsController < Morphosource::Dashboard::CollectionsController

        skip_load_and_authorize_resource only: [:edit, :update, :new, :members, :create_list], instance_name: :collection

        before_action :redirect_to_collection_type, only: []
        before_action :authorize_manager, only: [:create_list]

        self.presenter_class = Morphosource::Collections::ProjectPresenter

        def create_list
          list = @collection.fork_to_list(current_user)
          flash[:notice] = t('morphosource.dashboard.collections.project.edit.fork_project.notice')
          redirect_to media_list_path(list)
        rescue => e
          flash[:error] = t('morphosource.dashboard.collections.project.edit.fork_project.error', error_message: e.message)
          redirect_to project_edit_path(@collection)
        end

        private

          def collection_type
            Hyrax::CollectionType.find_by(title: "Project")
          end
          alias :default_collection_type :collection_type

          def authorize_manager
            redirect_to root_path and return unless current_user.can? :edit, @collection
          end

      end
    end
  end
end
