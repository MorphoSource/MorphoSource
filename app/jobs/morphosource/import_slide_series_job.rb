module Morphosource
  class ImportSlideSeriesJob < Hyrax::ApplicationJob

    queue_as Hyrax.config.update_medium_queue_name

    def perform(occurrence_key, collection_id = nil)
      Morphosource::Import::Slides::SlideSeriesService.new(occurrence_key, collection_id).call
    end
  end
end