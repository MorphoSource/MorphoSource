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
        if @collection.nil?
          flash[:error] = "There was an error importing resource id: #{resource_id}. Check the logs for more information."
          redirect_to import_slides_path
        else
          redirect_to sequential_section_list_path(@collection)
        end
      end

    private

      def require_admin
        authorize! :read, :admin_dashboard
      end
    end
  end
end
