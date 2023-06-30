module Morphosource
  module Admin
    class ImportSlidesController < ApplicationController
      before_action :require_admin
      with_themed_layout 'morphosource_dashboard'

      def index
      end

      def import_slides
        source = params["service"]
        resource_id = params["resource_id"]
        @collection = Morphosource::Import::Slides::SlideSeriesService.call(source: source, resource_id: resource_id)

        redirect_to sequential_section_list_path(@collection)
      end

    private

      def require_admin
        authorize! :read, :admin_dashboard
      end
    end
  end
end
