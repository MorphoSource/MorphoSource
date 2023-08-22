module Morphosource
  module Admin
    class ImportSlidesController < ApplicationController
      before_action :require_admin
      with_themed_layout 'morphosource_dashboard'

      def import_slides
        occurrence_id = params["occurrence_id"]
        @collection = Morphosource::Import::Slides::SlideSeriesService.call(occurrence_id)

        # this will be refactored w/ providers yml pr
        if import_error?
          redirect_to admin_import_slides_path, flash: { error: @error_message }
        else
          redirect_to sequential_section_list_path(@collection)
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
