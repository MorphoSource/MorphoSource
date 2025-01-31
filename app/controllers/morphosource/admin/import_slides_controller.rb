module Morphosource
  module Admin
    class ImportSlidesController < ApplicationController
      before_action :require_admin
      before_action :initialize_service, only: :import_slides

      with_themed_layout 'morphosource_dashboard'

      def index
        build_breadcrumbs
      end

      def import_slides
        Morphosource::ImportSlideSeriesJob.perform_later(occurrence_key, @collection.id)
        redirect_to sequential_section_list_path(@collection.id), flash: { notice: I18n.t('morphosource.admin.import.slides.job_submitted') }
      rescue StandardError => e
        redirect_to admin_import_slides_path, flash: { error: e.message }
      end

      def build_breadcrumbs
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb t(:'morphosource.dashboard.sidebar.admin_tools.management.import_slides'), main_app.admin_import_slides_path
      end

      private

        # initializing the service allows for checking that that GBIF occurrence json is available and valid before proceeding with the rest of the import, and makes the collection id available for the redirect in import_slides.
        def initialize_service
          @service = Morphosource::Import::Slides::SlideSeriesService.new(occurrence_key)
          @collection = @service.collection
        rescue StandardError => e
          redirect_to admin_import_slides_path, flash: { error: e.message }
        end

        def occurrence_key
          params["occurrence_key"]
        end

        def require_admin
          authorize! :read, :admin_dashboard
        end
    end
  end
end
