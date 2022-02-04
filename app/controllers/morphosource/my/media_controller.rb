module Morphosource
  module My
    class MediaController < Morphosource::My::WorksController

      def self.configure_facets
        configure_blacklight do |config|
          config.http_method = :post
          config.search_builder_class = self.new.search_builder_class
          # clear catalog facet fields
          config.facet_fields = {}
          config.add_facet_field "publication_status_ssi", label: "Publication Status", limit: 10
          config.add_facet_field "human_readable_media_type_ssim", label: "Media Type", limit: 10
          config.add_facet_field "media_organization_ssim", label: "Organization", limit: 10
          config.add_facet_field "member_of_project_ids_ssim", label: "Project", limit: 10, helper_method: :collection_title_by_id
          config.add_facet_field "member_of_team_ids_ssim", label: "Team", limit: 10, helper_method: :collection_title_by_id
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

      def sort_parameters
        s = (params[:sort].presence || '').split(' ')
        return s[0], s[1]
      end
      helper_method :sort_parameters

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
