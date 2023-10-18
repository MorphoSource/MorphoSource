module Morphosource
  module My
    module Collections
      class OrganizationCollectionsController < Morphosource::My::CollectionsController

        before_action :build_breadcrumbs, only: []

        # temporary restriction so only admins can access organization lists
        before_action :authorize_admin

        def collections_type
          "organizations"
        end

        def search_builder_class
          Morphosource::My::Collections::OrganizationsSearchBuilder
        end

        def search_action_url(*args)
          main_app.my_organizations_url(*args)
        end

        def search_action_for_dashboard
          main_app.my_organizations_path
        end

        private

          def add_collection_type_breadcrumb
            add_breadcrumb t(:'hyrax.admin.sidebar.organizations'), main_app.my_organizations_path
          end
      end
    end
  end
end