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


    def showcase
      @presenter = show_presenter.new(curation_concern_from_search_results, current_ability, request)
      render 'showcase', presenter: @presenter
    end

  end
end
