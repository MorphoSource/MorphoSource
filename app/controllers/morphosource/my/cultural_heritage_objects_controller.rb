module Morphosource
  module My
    class CulturalHeritageObjectsController < WorksController
      def self.configure_facets
        configure_blacklight do |config|
          config.http_method = :post
          config.search_builder_class = Morphosource::Users::MyChosSearchBuilder
          # clear catalog facet fields
          config.facet_fields = {}
          config.add_facet_field "organization", field: "organization_ssim", label: "Organization", limit: 10
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
            blacklight_config.search_builder_class = Morphosource::Users::EditChosSearchBuilder
          end
        end

        def search_action_url(*args)
          main_app.my_cultural_heritage_objects_path(*args)
        end

        # The url of the "more" link for additional facet values
        def search_facet_path(args = {})
          main_app.my_dashboard_chos_facet_path(args[:id])
        end

        def tab_variables
          @tab = :chos
          @tab_title = 'Cultural Heritage Objects // MorphoSource'
        end

    end
  end
end
