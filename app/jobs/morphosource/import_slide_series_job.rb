module Morphosource
  class ImportSlideSeriesJob < Hyrax::ApplicationJob

    queue_as Hyrax.config.update_medium_queue_name

    def perform(occurrence_id, json = nil, collection_id = nil)
      Morphosource::Import::Slides::SlideSeriesService.new(occurrence_id, json, collection_id).call
    end
  end
end