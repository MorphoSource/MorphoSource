# Generated via
#  `rails generate hyrax:work Taxonomy`
module Hyrax
  # Generated controller for Taxonomy
  class TaxonomiesController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Taxonomy

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::TaxonomyPresenter

    def show
      render 'hyrax/base/unauthorized', status: :unauthorized and return unless current_user&.admin?
      super
    end
  end
end
