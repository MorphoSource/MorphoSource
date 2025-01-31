module Morphosource
  module Dashboard
    module Collections
      class OrganizationCollectionsController < Morphosource::Dashboard::CollectionsController
      include Morphosource::Collections::OrganizationCollectionsControllerBehavior

        skip_load_and_authorize_resource only: [
          :create, :details, :edit, :members, :new, :ownership, :permissions, :projects, :update
        ], instance_name: :organization_collection

        before_action :redirect_to_collection_type, only: []
        before_action :build_breadcrumbs, only: []
        before_action :load_collection

        self.presenter_class = Morphosource::Collections::OrganizationPresenter

        self.form_class = Morphosource::Forms::Collections::OrganizationCollectionForm

        def edit
          @tab = :details
          add_breadcrumb t(:'hyrax.controls.home'), root_path
          add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
          add_breadcrumb t(:'morphosource.dashboard.collections.edit.header', type_title: 'Organization'), collection_edit_path(@collection), { "aria-current" => "page" }
          presenter
          form
        end

        def members
          @tab = :members
          add_members_breadcrumbs
          presenter
          form
        end

        # Compared to other routes, have to duplicate some logic from show page endpoints
        def ownership
          @tab = :ownership
          @object_ids = collection_object_ids
          add_ownership_breadcrumbs
          query_collection_counts
          query_media_management_counts
          presenter
          form
        end

        def permissions
          @tab = :permissions
          add_permissions_breadcrumbs
          presenter
          form
        end

        def projects
          @tab = :projects
          @projects = member_subcollections
          add_projects_breadcrumbs
          presenter
        end

        def add_members_breadcrumbs
          add_breadcrumb t(:'hyrax.controls.home'), root_path
          add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
          add_breadcrumb t(:'morphosource.dashboard.collections.edit.header', type_title: 'Organization'), collection_edit_path(@collection)
          add_breadcrumb t(:"morphosource.dashboard.collections.organization_collection.members.title"), organization_members_path(@collection)
        end

        def add_projects_breadcrumbs
          add_breadcrumb t(:'hyrax.controls.home'), root_path
          add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
          add_breadcrumb t(:'morphosource.dashboard.collections.edit.header', type_title: @collection.collection_type.title), collection_edit_path(@collection)
          add_breadcrumb t(:'morphosource.dashboard.collections.organization_collection.projects.title'), organization_projects_path(@collection)
        end

        def add_permissions_breadcrumbs
          add_breadcrumb t(:'hyrax.controls.home'), root_path
          add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
          add_breadcrumb t(:'morphosource.dashboard.collections.edit.header', type_title: @collection.collection_type.title), collection_edit_path(@collection)
          add_breadcrumb t(:'morphosource.dashboard.collections.organization_collection.permissions.title'), organization_permissions_path(@collection)
        end

        def add_ownership_breadcrumbs
          add_breadcrumb t(:'hyrax.controls.home'), root_path
          add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
          add_breadcrumb t(:'morphosource.dashboard.collections.edit.header', type_title: @collection.collection_type.title), collection_edit_path(@collection)
          add_breadcrumb t(:'morphosource.dashboard.collections.organization_collection.ownership.title'), organization_ownership_path(@collection)
        end

        private

          def default_collection_type
            Hyrax::CollectionType.find_by(title: "Organization")
          end

          def collection_class
            OrganizationCollection
          end

          def permissions_path
            organization_permissions_path(@organization)
          end

          def load_collection
            super
            @organization = @collection
          end
      end
    end
  end
end
