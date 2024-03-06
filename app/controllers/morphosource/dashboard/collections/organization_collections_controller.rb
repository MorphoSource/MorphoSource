module Morphosource
  module Dashboard
    module Collections
      class OrganizationCollectionsController < Morphosource::Dashboard::CollectionsController
        skip_load_and_authorize_resource only: [:edit, :update, :new, :members, :create, :details, :permissions], instance_name: :organization_collection

        before_action :redirect_to_collection_type, only: []
        before_action :build_breadcrumbs, only: []
        before_action :load_collection

        # temporary restriction so only admins can access organization collections
        # before_action :authorize_admin

        self.presenter_class = Morphosource::Collections::OrganizationPresenter

        self.form_class = Morphosource::Forms::Collections::OrganizationCollectionForm

        def edit
          @tab = :details
          presenter
          form
        end

        def members
          @tab = :members
          presenter
          form
        end

        def permissions
          @tab = :permissions
          presenter
          form
        end

        def projects
          @tab = :projects
          @projects = member_subcollections
          presenter
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
