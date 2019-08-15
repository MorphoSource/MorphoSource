# Generated via
#  `rails generate hyrax:work BiologicalSpecimen`
module Hyrax
  # Generated controller for BiologicalSpecimen
  class BiologicalSpecimensController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include Hyrax::ChildWorkRedirect
    self.curation_concern_type = ::BiologicalSpecimen
    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::BiologicalSpecimenPresenter

    # override the layout from WorksControllerBehavior
    def decide_layout
      layout = case action_name
               when 'show'
                 '1_column'
               when 'showcase'
                 'morphosource_2_columns'
               when 'new'
                 'morphosource_2_columns'
               when 'edit'
                 'morphosource_2_columns'
               else
                 'dashboard'
               end
      File.join(theme, layout)
    end

    def showcase
      @presenter = show_presenter.new(curation_concern_from_search_results, current_ability, request)
      render '/hyrax/physical_objects/showcase', presenter: @presenter
    end

    def edit
      build_form
      @presenter = show_presenter.new(curation_concern_from_search_results, current_ability, request)
      render '/hyrax/base/edit', presenter: @presenter
    end

  end

end
