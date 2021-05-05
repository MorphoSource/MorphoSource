module Morphosource
  module My
    class CulturalHeritageObjectsController < WorksController

      def self.configure_facets
        configure_blacklight do |config|
          config.http_method = :post
          config.search_builder_class = Morphosource::Users::MyChosSearchBuilder
          # clear catalog facet fields
          config.facet_fields = {}
          # source
          config.add_facet_field "organization_id_ssim", label: "Organization", helper_method: :organization_title_by_id
          config.add_facet_field "media_member_of_project_ids_ssim", label: "Project", helper_method: :collection_title_by_id
          config.add_facet_field "media_member_of_team_ids_ssim", label: "Team", helper_method: :collection_title_by_id
        end
      end
      configure_facets

      private

        def search_builder_class
          Morphosource::Users::MyChosSearchBuilder
        end

        def search_action_url(*args)
          main_app.my_cultural_heritage_objects_path(*args)
        end

        def tab_variables
          @tab = :chos
        end

    end
  end
end
