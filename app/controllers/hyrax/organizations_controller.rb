# Generated via
#  `rails generate hyrax:work Organization`
module Hyrax
  # Generated controller for Organization
  class OrganizationsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include Hyrax::ChildWorkRedirect

#include TeamsControllerBehavior
#    self.presenter_class = Hyrax::OrganizationPresenter
#    self.information_service_class = Morphosource::Organizations::OrganizationInformationService
    self.curation_concern_type = ::Organization
    self.show_presenter = Hyrax::OrganizationPresenter
#    self.member_service_class = Morphosource::Organizations::OrganizationMemberService

    with_themed_layout 'morphosource_1_column'

    def show
      @curation_concern ||= ActiveFedora::Base.find(params[:id])
      if @curation_concern.team_id.present?
        # If organization is linked to a team, this route should redirect to the org-linked team’s show page instead (MR-803)
        Rails.logger.info("MR-803: organization #{params[:id]} has team: #{@curation_concern.team_id.inspect}")
        redirect_to "/teams/#{@curation_concern.team_id.first}"
      else
        presenter
#query_collection_information
#byebug
#        query_collection_members

        member_works
      end
    end

    def member_service
      @member_service ||= Morphosource::Organizations::OrganizationMemberService.new
    end

    def member_works 

#      @response = member_service.bso_docs(@curation_concern)
#      @member_docs = @response.documents
#      @members_count = @response.total

      @bso_member_docs = member_service.bso_docs(@curation_concern)
      @bso_member_count = @bso_member_docs.total

@paged_bso_member_docs = @bso_member_docs
byebug
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
