# Generated via
#  `rails generate hyrax:work Device`
module Hyrax
  class DevicePresenter < Hyrax::WorkShowPresenter
    include Morphosource::PresenterMethods

    delegate :modality, :ark, to: :solr_document

    #
    # Modality (return one more more values)
    #
    # @return [String] modality
    #
    def device_modality
      @device_modality ||= modality.map{ |m| Morphosource::ModalitiesService.new.label(m) }.join(', ')
    end

    # methods for showcase partials
    def showcase_work_title_partial
      '/hyrax/devices/showcase_work_title'
    end

    def showcase_show_actions_partial
      '/hyrax/devices/showcase_show_actions'
    end

    def showcase_general_details_partial
      'showcase_general_details'
    end

  end
end
