module Morphosource
  module My
    class BiologicalSpecimensController < WorksController

      PAGE_TITLE = I18n.t("morphosource.dashboard.my.media_objects.biological_specimens.page_title")

      def self.configure_facets
        configure_blacklight do |config|
          config.http_method = :post
          config.search_builder_class = Morphosource::Users::MySpecimensSearchBuilder
          # clear catalog facet fields
          config.facet_fields = {}
          config.add_facet_field "record_source", field: "record_source_ssim", label: "Source", limit: 10
          config.add_facet_field "organization", field: "organization_ssim", label: "Organization", limit: 10
          config.add_facet_field "taxonomy_name", field: "taxonomy_ssim", label: "Taxonomy (Name)", limit: 10
          config.add_facet_field "taxonomy_gbif", field: "external_taxonomy_ssim", label: "Taxonomy (GBIF)", limit: 25
          config.add_facet_field "media_type", field: "public_media_type_ssim", label: "Media Type", limit: 10
          config.add_facet_field "team", field: "media_member_of_team_ids_ssim", label: "Team", limit: 10, helper_method: :collection_title_by_id
          config.add_facet_field "project", field: "media_member_of_project_ids_ssim", label: "Project", limit: 10, helper_method: :collection_title_by_id
        end
      end
      configure_facets

      before_action :modify_search_builder_class_for_admin, only: [:index]

      private
        # If user is admin, use different search builder class
        def modify_search_builder_class_for_admin
          if current_user&.admin?
            blacklight_config.search_builder_class = Morphosource::Users::EditSpecimensSearchBuilder
          end
        end

        # The url of the "more" link for additional facet values
        def search_facet_path(args = {})
          main_app.my_dashboard_specimens_facet_path(args[:id])
        end

        def search_action_url(*args)
          main_app.my_specimens_path(*args)
        end

        def tab_variables
          @tab = :specimens
          @tab_title = 'Specimens // MorphoSource'
        end

    end
  end
end
