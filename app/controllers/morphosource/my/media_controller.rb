module Morphosource
  module My
    class MediaController < WorksController

      def self.configure_facets
        configure_blacklight do |config|
          config.http_method = :post
          config.search_builder_class = self.new.search_builder_class
          # clear catalog facet fields
          config.facet_fields = {}
          config.add_facet_field "publication_status_ssi", label: "Publication Status"
          config.add_facet_field "human_readable_media_type_ssim", label: "Media Type"
          config.add_facet_field "media_organization_id_ssim", label: "Organization", helper_method: :organization_title_by_id, limit: 10
          config.add_facet_field "member_of_project_ids_ssim", label: "Project", helper_method: :collection_title_by_id, limit: 10
          config.add_facet_field "member_of_team_ids_ssim", label: "Team", helper_method: :collection_title_by_id, limit: 10
        end
      end
      configure_facets

      def search_builder_class
        if current_user.admin?
          Morphosource::Users::EditMediaSearchBuilder
        else
          Morphosource::Users::MyMediaSearchBuilder
        end
      end

      private

        # The url of the "more" link for additional facet values
        def search_facet_path(args = {})
          main_app.my_dashboard_media_facet_path(args[:id])
        end

        def search_action_url(*args)
          main_app.my_media_index_path(*args)
        end

        def tab_variables
          @tab = :media
          @tab_title = 'Media // MorphoSource'
        end
    end
  end
end
