# Generated via
#  `rails generate hyrax:work ImageCaptureEvent`
module Hyrax
  # Generated controller for ImageCaptureEvent
  class ImageCaptureEventsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::ImageCaptureEvent

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::ImageCaptureEventPresenter
  end
end
