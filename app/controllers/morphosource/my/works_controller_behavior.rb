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

      # removes facet limits for non-admins
      def set_facet_limit
        limit = ms_default_facet_limit
        @blacklight_config.facet_fields.each do |k,v|
          v.limit = limit
        end
      end

      # overrides https://github.com/projectblacklight/blacklight/blob/c310fc8cb07635cac8e2474b1afa9fafdb6c89de/app/controllers/concerns/blacklight/catalog.rb#L154
      def facet_limit_for(facet_field)
        facet = blacklight_config.facet_fields[facet_field]
        return if facet.blank?

        if @response && @response.aggregations[facet.field]
          ms_default_facet_limit
        elsif facet.limit
          facet.limit == true ? DEFAULT_FACET_LIMIT : facet.limit
        end
      end
      deprecation_deprecate facet_limit_for: 'moving to private logic in Blacklight::FacetFieldPresenter'
    end
  end
end
