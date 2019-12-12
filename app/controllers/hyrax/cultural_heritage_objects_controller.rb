# Generated via
#  `rails generate hyrax:work CulturalHeritageObject`
module Hyrax
  # Generated controller for CulturalHeritageObject
  class CulturalHeritageObjectsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include Hyrax::ChildWorkRedirect
    self.curation_concern_type = ::CulturalHeritageObject
    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::CulturalHeritageObjectPresenter

    # override the layout from WorksControllerBehavior
    def decide_layout
      layout = case action_name
               when 'show'
                 '1_column'
               when 'showcase'
                 'morphosource_2_columns'
               # todo: later might need to add different layout for EDIT or other actions here
               else
                 'dashboard'
               end
      File.join(theme, layout)
    end

    def showcase
      @presenter = show_presenter.new(curation_concern_from_search_results, current_ability, request)
      render '/hyrax/physical_objects/showcase', presenter: @presenter
    end

  end
end
