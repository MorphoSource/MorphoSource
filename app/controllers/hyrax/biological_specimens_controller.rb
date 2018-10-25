# Generated via
#  `rails generate hyrax:work BiologicalSpecimen`
module Hyrax
  # Generated controller for BiologicalSpecimen
  class BiologicalSpecimensController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::BiologicalSpecimen

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::BiologicalSpecimenPresenter
  end
end
