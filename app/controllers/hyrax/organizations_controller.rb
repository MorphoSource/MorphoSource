# Generated via
#  `rails generate hyrax:work Organization`
module Hyrax
  # Generated controller for Organization
  class OrganizationsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include Hyrax::ChildWorkRedirect

    include TeamsControllerBehavior
    self.presenter_class = Hyrax::OrganizationPresenter
    self.information_service_class = Morphosource::Organizations::OrganizationInformationService

    self.curation_concern_type = ::Organization

    self.show_presenter = Hyrax::OrganizationPresenter
    with_themed_layout 'morphosource_1_column'

    def show
      @curation_concern ||= ActiveFedora::Base.find(params[:id])
      if @curation_concern.team_id.present?
        Rails.logger.info("MR-803: organization #{params[:id]} has team: #{@curation_concern.team_id.inspect}")
        redirect_to "/teams/#{@curation_concern.team_id.first}"
      else
        presenter
        query_collection_information
        query_collection_members
      end
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
