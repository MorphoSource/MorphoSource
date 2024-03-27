# Generated via
#  `rails generate hyrax:work Device`
module Hyrax
  class DevicePresenter < Hyrax::WorkShowPresenter
    include Morphosource::PresenterMethods

    delegate :modality, :ark, to: :solr_document
  end
end
