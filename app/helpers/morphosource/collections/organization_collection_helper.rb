module Morphosource
  module Collections
    module OrganizationCollectionHelper

      def device_modalities(modalities)
        modalities.sort.map { |modality| "#{modality_label(modality)}" }.join('</br>').html_safe
      end

      def modality_label(key)
        Morphosource::ModalitiesService.new.label(key)
      end

      def device_media_and_imaging_event_counts(id)
        media_search = total_viewable_device_media(id)
        media_count = media_search.response['numFound']
        imaging_event_count = total_viewable_device_imaging_events(media_search)
        [media_count, imaging_event_count]
      end

      # MorphoSource::DeviceMediaSearchBuilder
      # search for media with device id
      def total_viewable_device_media(id)
        Morphosource::DeviceMediaSearchService.new(self, id).search
      end

      # count of imaging events for media viewable by current user
      # prevents users seeing a confusing discrepancy if there are lots of private media
      # uses imaging_event_id facet to get the number of unique imaging events
      def total_viewable_device_imaging_events(media_search)
        Hash[*media_search.facet_fields['imaging_event_id_tesim'].flatten].keys.count
      end
    end
  end
end