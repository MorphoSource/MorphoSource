module Morphosource
  module My
    class BiologicalSpecimensController < WorksController

      def self.configure_facets
        configure_blacklight do |config|
          config.http_method = :post
          config.search_builder_class = self.new.search_builder_class
          # clear catalog facet fields
          config.facet_fields = {}
          config.add_facet_field "record_source_ssim", label: "Source"
          config.add_facet_field "organization_ssim", label: "Organization"
          config.add_facet_field "media_member_of_project_ids_ssim", label: "Project", helper_method: :collection_title_by_id
          config.add_facet_field "media_member_of_team_ids_ssim", label: "Team", helper_method: :collection_title_by_id
        end
      end
      configure_facets

      def search_builder_class
        if current_user.admin?
          Morphosource::Users::EditSpecimensSearchBuilder
        else
          Morphosource::Users::MySpecimensSearchBuilder
        end
      end

      private

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
