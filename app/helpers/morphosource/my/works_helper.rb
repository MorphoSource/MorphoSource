module Morphosource
  module My
    module WorksHelper

      def active_tab?(tab)
        @tab == tab ? 'active' : ''
      end

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
        ActiveFedora::Base.where("physical_object_id_tesim:#{id} AND has_model_ssim:Media").accessible_by(current_ability).count
      end

      # Overrides https://github.com/projectblacklight/blacklight/blob/3120185709271c39f702a4ba176c5ad3865684d6/app/helpers/blacklight/facets_helper_behavior.rb#L63
      # Removes projects and teams from facets when the user does not have read access to them.
      def render_facet_item(facet_field, item)
        return nil if filtered_facet?(facet_field) && item_unauthorized?(item)
        super
      end

      def filtered_facet?(facet_field)
        filtered_facets = ["member_of_project_ids_ssim",
                           "member_of_team_ids_ssim",
                           "media_member_of_project_ids_ssim",
                           "media_member_of_team_ids_ssim"]
        filtered_facets.include? facet_field
      end

      # An item is unauthorized if its value (collection id) is not included in the array of ids a user is able to read.
      def item_unauthorized?(item)
        !@viewable_collections_ids.include? item.value
      end

    end
  end
end
