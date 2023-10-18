module Morphosource
  module Dashboard
    module Collections
      class OrganizationCollectionsController < Morphosource::Dashboard::CollectionsController
        skip_load_and_authorize_resource only: [:edit, :update, :new, :members, :create], instance_name: :organization_collection

        before_action :redirect_to_collection_type, only: []
        before_action :build_breadcrumbs, only: []
        before_action :load_collection

        # temporary restriction so only admins can access media lists and sequential section lists
        before_action :authorize_admin

        self.presenter_class = Morphosource::Collections::OrganizationPresenter

        self.form_class = Morphosource::Forms::Collections::OrganizationForm

        private

          def default_collection_type
            Hyrax::CollectionType.find_by(title: "Organization")
          end

          def collection_class
            OrganizationCollection
          end
      end
    end
  end
end
