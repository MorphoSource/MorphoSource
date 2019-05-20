# Generated via
#  `rails generate hyrax:work ProcessingEventActivity`
module Hyrax
  # Generated controller for ProcessingEventActivity
  class ProcessingEventActivitiesController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::ProcessingEventActivity

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::ProcessingEventActivityPresenter
  end
end
