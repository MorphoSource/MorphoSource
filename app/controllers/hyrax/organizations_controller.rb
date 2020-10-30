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

#    self.curation_concern_type = ::Organization


    with_themed_layout 'morphosource_1_column'

    def query_organization_information
      @organization_information = organization_information_service.organization_information
#      @collection_counts = @collection_information['counts'] ||= {}
#      @collection_groups = @collection_information['collection_groups'] ||= {}
    end

    def organization_information_service
      @organization_information_service ||= information_service_class.new(curation_concern.id) 
    end

    def update
      if update_work
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
  end
end
