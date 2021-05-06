module Morphosource
  module My
    class MediaController < WorksController

      def self.configure_facets
        configure_blacklight do |config|
          config.http_method = :post
          byebug
          config.search_builder_class = Morphosource::Users::MyMediaSearchBuilder
          # clear catalog facet fields
          config.facet_fields = {}
          config.add_facet_field "publication_status_ssi", label: "Publication Status"
          config.add_facet_field "human_readable_media_type_ssim", label: "Media Type"
          # change to ids?
          config.add_facet_field "media_organization_ssim", label: "Organization"
          config.add_facet_field "member_of_project_ids_ssim", label: "Project", helper_method: :collection_title_by_id
          config.add_facet_field "member_of_team_ids_ssim", label: "Team", helper_method: :collection_title_by_id
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

        def search_action_url(*args)
          main_app.my_media_index_path(*args)
        end

        def tab_variables
          @tab = :media
        end
    end
  end
end
