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

    # override the layout from WorksControllerBehavior
    def decide_layout
      layout = case action_name
               when 'show'
                 '1_column'
               when 'showcase'
                 'morphosource_2_columns'
               #when 'new'
               #  'morphosource_2_columns'
               when 'edit'
                 'morphosource_2_columns'
               else
                 'dashboard'
               end
      File.join(theme, layout)
    end

    def showcase
      @presenter = show_presenter.new(curation_concern_from_search_results, current_ability, request)
      render 'showcase', presenter: @presenter
    end

    def new
      build_form
      #@presenter = show_presenter.new(curation_concern_from_search_results, current_ability, request)
      #@presenter.get_organization_data
      render '/hyrax/base/new' #, presenter: @presenter
    end

    # overriding action methods from works_controller_behavior.rb
    def edit
      build_form
      @presenter = show_presenter.new(curation_concern_from_search_results, current_ability, request)
      @new_organization_submit_submissions_url = '/submissions/new_organization_submit'
      @new_organization_form = Hyrax::WorkFormService.build(::Organization.new, current_ability, self)
      @countries_service = Morphosource::CountriesService.new
      render 'edit', presenter: @presenter
    end
  end
end
