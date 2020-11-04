# Generated via
#  `rails generate hyrax:work Organization`
module Hyrax

  # Generated controller for Organization
  class OrganizationsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include Hyrax::ChildWorkRedirect
    include OrganizationsControllerBehavior

    self.curation_concern_type = ::Organization
    with_themed_layout 'morphosource_1_column'


    def edit
      build_form
      @presenter = presenter_class.new(@curation_concern, current_ability, request)
      #@presenter = presenter_class.new(curation_concern_from_search_results, current_ability, request)
      render '/hyrax/base/edit', presenter: @presenter
    end

    def update
      if actor.update(actor_environment)
        after_update_response
      else
        respond_to do |wants|
          wants.html do
            build_form
            render 'edit', status: :unprocessable_entity
          end
          wants.json { render_json_response(response_type: :unprocessable_entity, options: { errors: curation_concern.errors }) }
        end
      end

    end

    def after_update_response
      respond_to do |wants|
        wants.html { 
          byebug
            build_form
            render 'edit', status: :unprocessable_entity
          #redirect_to Rails.application.routes.url_helpers.show_organization_path(curation_concern.id)
          #, notice: "Work \"#{curation_concern}\" successfully updated." 
        }
        #wants.json { render :show, status: :ok, location: polymorphic_path([main_app, curation_concern]) }
      end
    end

  end
end
