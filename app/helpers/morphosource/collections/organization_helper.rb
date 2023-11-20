module Morphosource
  module Collections
    module OrganizationHelper

      def device_modalities(modalities)
        modalities.sort.map { |modality| "#{modality_label(modality)}" }.join('</br>').html_safe
      end

      def modality_label(key)
        Morphosource::ModalitiesService.new.label(key)
      end

      def device_media_and_imaging_event_counts(id)
        media = total_viewable_device_media(id)
        media_count = media.count
        imaging_event_count = media.map(&:imaging_event_id).flatten.uniq.count
        [media_count, imaging_event_count]
      end

      # MorphoSource::DeviceMediaSearchBuilder
      def total_viewable_device_media(id)
        Morphosource::DeviceMediaSearchService.new(self, id).search_results
      end

      def total_viewable_device_media_count(id)
        total_viewable_device_media(id).count
      end

      # count of imaging events for media viewable by current user
      # prevents users seeing a confusing discrepancy if there are lots of private media
      def total_viewable_device_imaging_events(id)
        total_viewable_device_media(id).map(&:imaging_event_id).flatten.uniq.count
      end

    end
  end
end