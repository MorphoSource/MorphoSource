# Generated via
#  `rails generate hyrax:work CulturalHeritageObject`
module Hyrax
  # Generated controller for CulturalHeritageObject
  class CulturalHeritageObjectsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::CulturalHeritageObject

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::CulturalHeritageObjectPresenter
  end
end
