module Morphosource
  module Admin
    class ImportSlidesController < ApplicationController
      before_action :require_admin
      with_themed_layout 'morphosource_dashboard'

      before_action :initialize_service, only: :import_slides

      def import_slides
        Morphosource::ImportSlideSeriesJob.perform_later(occurrence_id, @occurrence_json, @collection.id)
        redirect_to sequential_section_list_path(@collection.id), flash: { notice: I18n.t('morphosource.admin.import.slides.job_submitted') }
      rescue StandardError => e
        redirect_to admin_import_slides_path, flash: { error: e.message }
      end

      private

        # initializing the service allows for checking that that GBIF occurrence json is available and valid before proceeding with the rest of the import, and makes the collection id available for the redirect in import_slides.
        def initialize_service
          @service = Morphosource::Import::Slides::SlideSeriesService.new(occurrence_id)
          @collection = @service.collection
          @occurrence_json = @service.occurrence_json
        rescue StandardError => e
          redirect_to admin_import_slides_path, flash: { error: e.message }
        end

        def occurrence_id
          params["occurrence_id"]
        end

        def require_admin
          authorize! :read, :admin_dashboard
        end
    end
  end
end
