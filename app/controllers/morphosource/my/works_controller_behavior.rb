module Morphosource
  module My
    module WorksControllerBehavior
      extend ActiveSupport::Concern

      def add_breadcrumbs
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
      end

      def collections_service
        Hyrax::CollectionsService.new(self)
      end

      # populates media/object counts at top of page
      def get_media_object_counts
        @media_count_for_edit = media_count_for_edit
        @media_count_for_view = media_count_for_view
        @po_count_for_edit = po_count_for_edit
      end

      def media_count_for_view
        response =  Morphosource::UserWorksSearchService.call('media','read',self).response
        response["numFound"]
      end

      def media_count_for_edit
        response = Morphosource::UserWorksSearchService.call('media','edit',self).response
        response["numFound"]
      end

      def po_count_for_edit
        response =  Morphosource::UserWorksSearchService.call('object', 'edit', self).response
        response["numFound"]
      end

      def viewable_collections_ids
        ActiveFedora::Base.where("has_model_ssim:Collection").accessible_by(current_ability, :read).map(&:id)
      end

    end
  end
end
