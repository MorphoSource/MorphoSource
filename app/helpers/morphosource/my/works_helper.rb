module Morphosource
  module My
    module WorksHelper

      # sets class to highlight tab for current page
      def active_tab?(tab)
        @tab == tab ? 'active' : ''
      end

      # TODO - refactor? using for collections show pages
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
        when "morphosource/collections/projects"
          main_app.project_media_path
        when "morphosource/collections/teams"
          main_app.team_media_path
        when "morphosource/collections/media_lists"
          main_app.media_list_media_path
        when "morphosource/collections/media_lists/sequential_section_lists"
          main_app.sequential_section_list_media_path
        when "morphosource/collections/biological_specimens"
          if @collection.project?
            main_app.project_specimens_path
          elsif @collection.team?
            main_app.team_specimens_path
          elsif @collection.media_list?
            main_app.media_list_specimens_path
          elsif @collection.sequential_section_list?
            main_app.sequential_section_list_specimens_path
          end
        when "morphosource/collections/cultural_heritage_objects"
          if @collection.project?
            main_app.project_chos_path
          elsif @collection.team?
            main_app.team_chos_path
          elsif @collection.media_list?
            main_app.media_list_chos_path
          elsif @collection.sequential_section_list?
            main_app.sequential_section_list_chos_path
          end
        else
          # hyrax/my/works controller and default cases.
          hyrax.my_works_path
        end
      end

      def total_viewable_media(id)
        Morphosource::PhysicalObjectMediaSearchService.new(self, id).search_results.count
      end

      def sortable_table_header(label, param_name)
        sort_col, sort_dir = sort_parameters
        if sort_col == param_name && sort_dir.downcase == 'asc'
          link_to request.params.merge(sort: "#{param_name} desc"), class: 'table-sort-header' do
            (label + ' <span class="glyphicon glyphicon-sort-by-attributes" aria-hidden="true"></span>').html_safe
          end
        elsif sort_col == param_name && sort_dir.downcase == 'desc'
          link_to request.params.merge(sort: "#{param_name} asc"), class: 'table-sort-header' do
            (label + ' <span class="glyphicon glyphicon-sort-by-attributes-alt" aria-hidden="true"></span>').html_safe
          end
        else
          link_to request.params.merge(sort: "#{param_name} asc"), class: 'table-sort-header' do
            (label + ' <span class="glyphicon glyphicon-sort" aria-hidden="true"></span>').html_safe
          end
        end
      end
    end
  end
end
