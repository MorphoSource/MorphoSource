module Morphosource
  module Collections
    module OrganizationHelper

      def device_modalities(modalities)
        modalities.sort.map { |modality| "#{modality_label(modality)}" }.join('</br>').html_safe
      end

      def modality_label(key)
        Morphosource::ModalitiesService.new.label(key)
      end

      # MorphoSource::DeviceMediaSearchBuilder
      def total_viewable_device_media(id)
        Morphosource::DeviceMediaSearchService.new(self, id).search_results.count
      end

    end
  end
end