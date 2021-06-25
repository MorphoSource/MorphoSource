module Morphosource
  module My
    module WorksHelper

      # sets class to highlight tab for current page
      def active_tab?(tab)
        @tab == tab ? 'active' : ''
      end

      # search box action
      def search_action_for_dashboard
        case params[:controller]
        when "hyrax/my/collections"
          hyrax.my_collections_path
        when "hyrax/my/shares"
          hyrax.dashboard_shares_path
        when "hyrax/my/highlights"
          hyrax.dashboard_highlights_path
        when "hyrax/dashboard/works"
          hyrax.dashboard_works_path
        when "hyrax/dashboard/collections"
          hyrax.dashboard_collections_path
        when "morphosource/my/media"
          main_app.my_media_index_path
        when "morphosource/my/add_media"
          main_app.my_add_media_index_path
        when "morphosource/my/biological_specimens"
          main_app.my_specimens_path
        when "morphosource/my/cultural_heritage_objects"
          main_app.my_cultural_heritage_objects_path
        else
          # hyrax/my/works controller and default cases.
          hyrax.my_works_path
        end
      end

      def total_viewable_media(id)
        Morphosource::PhysicalObjectMediaSearchService.new(self, id).search_results.count
      end

    end
  end
end
