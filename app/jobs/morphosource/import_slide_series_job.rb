module Morphosource
  class ImportSlideSeriesJob < Hyrax::ApplicationJob

    queue_as Hyrax.config.update_medium_queue_name

    def perform(occurrence_key, collection_id = nil)
      Rails.logger.info "[Morphosource::ImportSlideSeriesJob] Performing job to import slide series for occurrence key: #{occurrence_key} and collection id: #{collection_id}"
      Morphosource::Import::Slides::SlideSeriesService.new(occurrence_key, collection_id).call
    end
  end
end