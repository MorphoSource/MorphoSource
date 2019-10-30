# Generated via
#  `rails generate hyrax:work Organization`
module Hyrax
  # Generated controller for Organization
  class OrganizationsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include Hyrax::ChildWorkRedirect
    self.curation_concern_type = ::Organization

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::OrganizationPresenter
  end
end
