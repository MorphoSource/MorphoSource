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
    with_themed_layout 'morphosource_1_column'

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::DevicePresenter

    # Update work index after initial creation to ensure index reflects organization metadata
    def after_create_response
      curation_concern.update_index if curation_concern.id.present?
      super
    end
  end
end
