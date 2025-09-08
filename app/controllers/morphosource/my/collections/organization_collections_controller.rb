module Morphosource
  module My
    module Collections
      class OrganizationCollectionsController < Morphosource::My::CollectionsController

        # Define collection specific filter facets.
        def self.configure_facets
          configure_blacklight do |config|
            config.http_method = :post
            config.search_builder_class = Morphosource::My::Collections::OrganizationsSearchBuilder
            # clear catalog facet fields
            config.facet_fields = {}
            # membership facet added in before_action :create_membership_facet
            config.add_facet_field "institution", field: "institution_name_ssim", label: "Institution", limit: 10
            config.add_facet_field "organization_type", field: "organization_type_ssim", label: "Organization Type", limit: 10
            config.add_facet_field "country", field: "country_ssim", label: "Country", limit: 10
            config.add_facet_field "state", field: "state_province_ssim", label: "State or Province", limit: 10
            config.add_facet_field "city", field: "city_ssim", label: "City", limit: 10
          end
        end
        configure_facets

        def collections_type
          "organizations"
        end

        def search_builder_class
          Morphosource::My::Collections::OrganizationsSearchBuilder
        end

        # The url of the "more" link for additional facet values
        def search_facet_path(args = {})
          main_app.my_organizations_facet_path(args[:id])
        end

        def search_action_url(*args)
          main_app.my_organizations_url(*args)
        end

        def search_action_for_dashboard
          main_app.my_organizations_path
        end

        private

          def add_collection_type_breadcrumb
            add_breadcrumb t(:'morphosource.dashboard.sidebar.my_media_collections.organizations'), main_app.my_organizations_path, { "aria-current" => "page" }
          end
      end
    end
  end
end