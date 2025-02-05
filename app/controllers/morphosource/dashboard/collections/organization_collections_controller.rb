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
          presenter
          form
        end

        def update
          create_attachment_if_needed
          super
        end

        def create_attachment_if_needed
          # Handle possible attachment upload
          if params[:media_attachment_delete] == 'delete'
            @organization.agreement_attachment = nil
            params.delete(:media_attachment_delete)
          end
          if params[:agreement] && Morphosource.attachment_formats.include?(File.extname(params[:agreement].original_filename))
            @organization.agreement_attachment = params[:agreement]
            params.delete(:agreement)
          end
        end

        def members
          @tab = :members
          presenter
          form
        end

        # Compared to other routes, have to duplicate some logic from show page endpoints
        def ownership
          @tab = :ownership
          @object_ids = collection_object_ids
          query_collection_counts
          query_media_management_counts
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
