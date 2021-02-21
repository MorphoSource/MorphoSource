# Generated via
#  `rails generate hyrax:work EngineeringObject`
module Hyrax
  # Generated controller for EngineeringObject
  class EngineeringObjectsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::EngineeringObject

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::EngineeringObjectPresenter
  end
end
