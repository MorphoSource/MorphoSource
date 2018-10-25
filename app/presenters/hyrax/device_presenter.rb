# Generated via
#  `rails generate hyrax:work Device`
module Hyrax
  class DevicePresenter < Hyrax::WorkShowPresenter
  	delegate :facility, :modality, to: :solr_document
  end
end
