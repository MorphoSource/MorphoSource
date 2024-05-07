# Generated via
#  `rails generate hyrax:work Device`
module Hyrax
  class DevicePresenter < Hyrax::WorkShowPresenter
    include Morphosource::PresenterMethods

    delegate :modality, to: :solr_document

    # methods for showcase partials
    def showcase_work_title_partial
      '/hyrax/devices/showcase_work_title'
    end

    def showcase_show_actions_partial
      '/hyrax/devices/showcase_show_actions'
    end

  end
end
