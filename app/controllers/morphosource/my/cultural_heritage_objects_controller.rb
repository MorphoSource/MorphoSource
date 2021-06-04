module Morphosource
  module My
    class CulturalHeritageObjectsController < WorksController

      def self.configure_facets
        configure_blacklight do |config|
          config.http_method = :post
          config.search_builder_class = self.new.search_builder_class
          # clear catalog facet fields
          config.facet_fields = {}
          config.add_facet_field "organization_ssim", label: "Organization", limit: 10
          config.add_facet_field "media_member_of_project_ids_ssim", label: "Project", helper_method: :collection_title_by_id, limit: 10
          config.add_facet_field "media_member_of_team_ids_ssim", label: "Team", helper_method: :collection_title_by_id, limit: 10
        end
      end
      configure_facets

      def search_builder_class
        if current_user.admin?
          Morphosource::Users::EditChosSearchBuilder
        else
          Morphosource::Users::MyChosSearchBuilder
        end
      end

      private

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
