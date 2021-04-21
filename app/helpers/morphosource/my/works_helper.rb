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
        else
          # hyrax/my/works controller and default cases.
          hyrax.my_works_path
        end
      end

      def total_viewable_media(id)
        ActiveFedora::Base.where("physical_object_id_tesim:#{id} AND has_model_ssim:Media").accessible_by(current_ability).count
      end
    end
  end
end
