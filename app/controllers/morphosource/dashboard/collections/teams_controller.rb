module Morphosource
  module Dashboard
    module Collections
      class TeamsController < Morphosource::Dashboard::CollectionsController

        skip_load_and_authorize_resource only: [:edit, :update, :new, :projects, :organization, :members], instance_name: :collection

        before_action :redirect_to_collection_type, only: []
        before_action :build_breadcrumbs, only: []
        before_action :load_collection

        self.presenter_class = Morphosource::Collections::TeamPresenter

        def edit
          organization_presenter
          super
        end

        def projects
          @tab = :projects
          @projects = member_subcollections
          add_breadcrumb t(:'hyrax.controls.home'), root_path
          add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
          add_breadcrumb t(:'morphosource.dashboard.collections.edit.header', type_title: @collection.collection_type.title), collection_edit_path(@collection)
          add_breadcrumb t(:'morphosource.dashboard.collections.team.projects.title'), team_projects_path(@collection)
          presenter
          render 'edit'
        end

        def organization
          @tab = :organization
          @organization = @collection.organization
          add_breadcrumb t(:'hyrax.controls.home'), root_path
          add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
          add_breadcrumb t(:'morphosource.dashboard.collections.edit.header', type_title: @collection.collection_type.title), collection_edit_path(@collection)
          add_breadcrumb t(:'morphosource.dashboard.collections.team.organization.title'), team_organization_path(@collection)
          organization_presenter
          presenter
          form
          render 'edit'
        end

        private

          def default_collection_type
            Hyrax::CollectionType.find_by(title: "Team")
          end

          def organization_presenter
            @organization ||= @collection.organization
            return nil unless @organization

            Hyrax::OrganizationPresenter.new(@organization, current_ability, nil)
          end

      end
    end
  end
end
