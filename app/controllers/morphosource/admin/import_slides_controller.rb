module Morphosource
  module Admin
    class ImportSlidesController < ApplicationController
      before_action :require_admin
      with_themed_layout 'morphosource_dashboard'

      def index

      end

      def import_slides
        service = params["service"]
        resource_id = params["resource_id"]
        user_email = params["user_email"]
        @collection = Morphosource::Import::SlideSeriesService.new(service,resource_id,user_email).call

        redirect_to project_media_path(@collection)
      end

    private

      def require_admin
        authorize! :read, :admin_dashboard
      end
    end
  end
end
