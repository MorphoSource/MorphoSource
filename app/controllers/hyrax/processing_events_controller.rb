# Generated via
#  `rails generate hyrax:work ProcessingEvent`
module Hyrax
  # Generated controller for ProcessingEvent
  class ProcessingEventsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::ProcessingEvent

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::ProcessingEventPresenter
  end
end
