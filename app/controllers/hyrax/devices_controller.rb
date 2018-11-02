# Generated via
#  `rails generate hyrax:work Device`
module Hyrax
  # Generated controller for Device
  class DevicesController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include Hyrax::ChildWorkRedirect
    self.curation_concern_type = ::Device

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::DevicePresenter
  end
end
