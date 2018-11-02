# Generated via
#  `rails generate hyrax:work Institution`
module Hyrax
  # Generated controller for Institution
  class InstitutionsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include Hyrax::ChildWorkRedirect
    self.curation_concern_type = ::Institution

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::InstitutionPresenter
  end
end
