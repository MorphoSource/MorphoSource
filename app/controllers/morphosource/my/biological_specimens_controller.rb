module Morphosource
  module My
    class BiologicalSpecimensController < WorksController

      def self.configure_facets
        configure_blacklight do |config|
          config.http_method = :post
          config.search_builder_class = Morphosource::Users::MySpecimensSearchBuilder
          # clear catalog facet fields
          config.facet_fields = {}
          config.add_facet_field "organization_id_ssim", label: "Organization", helper_method: :organization_title_by_id
          config.add_facet_field "media_member_of_project_ids_ssim", label: "Project", helper_method: :collection_title_by_id
          config.add_facet_field "media_member_of_team_ids_ssim", label: "Team", helper_method: :collection_title_by_id
        end
      end
      configure_facets

      private

        def search_builder_class
          Morphosource::Users::MySpecimensSearchBuilder
        end

        def search_action_url(*args)
          main_app.my_specimens_path(*args)
        end

        def tab_variables
          @tab = :specimens
        end

    end
  end
end
