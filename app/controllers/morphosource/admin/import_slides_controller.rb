module Morphosource
  module Admin
    class ImportSlidesController < ApplicationController
      before_action :require_admin
      with_themed_layout 'morphosource_dashboard'

      def index
      end

      def import_slides
        organization_id = params["organization"]
        service = params["service"]
        resource_id = params["resource_id"]
        user_email = params["user_email"]
        list_visibility = params["list_visibility"]
        @collection = import_service_class.new(service: service, resource_id:resource_id, user_email: user_email).call

        # this will be refactored w/ providers yml pr
        if import_error?
          redirect_to admin_import_slides_path, flash: { error: @error_message }
        else
          redirect_to sequential_section_list_path(@collection)
        end
      end

      def import_service_class
        case params["organization"]
        when "MCZ"
          Morphosource::Import::MczSlideSeriesService
        end
      end

    private

      def require_admin
        authorize! :read, :admin_dashboard
      end

      def import_error?
        return false unless @collection.is_a? String

        @error_message = @collection
        true
      end
    end
  end
end
