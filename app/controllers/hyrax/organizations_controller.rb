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


    def url_for(child)
      # this method is a temp fix for the error when loading edit org page:
      # arguments passed to url_for can't be handled. Please require routes or provide your own implementation
      return '/dashboard'
    end

    def after_update_response
      respond_to do |wants|
        wants.html { 
          redirect_to Rails.application.routes.url_helpers.show_organization_path(curation_concern.id)
        }
        #wants.json { render :show, status: :ok, location: polymorphic_path([main_app, curation_concern]) }
      end
    end

  end
end
