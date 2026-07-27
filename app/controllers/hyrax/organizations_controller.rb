module Hyrax

  # Generated controller for Organization
  class OrganizationsController < ApplicationController
    # Adds Hyrax behaviors to the controller
    include Morphosource::CurationConcernControllerBehavior
    include Hyrax::WorksControllerBehavior
    include Hyrax::ChildWorkRedirect
    include OrganizationsControllerBehavior
    include Morphosource::OrganizationHelper
    prepend Morphosource::HaltedDestroyResponse
    helper_method :showpage_url, :hidden_params_for_filters, :publication_status_label, :media_type_label,
      :ms_organization_view_link_qs, :ms_organization_view_link, :hidden_params_for_pagination, :source_label

    self.curation_concern_type = ::Organization
    with_themed_layout 'morphosource_1_column'

    skip_load_and_authorize_resource only: :unlinked_organizations

    before_action :set_default_view, only: [:show]

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

    # search for organizations without team ids by title.
    # returns json: unlinked_organizations.json.jbuilder
    def unlinked_organizations
      return unless current_user.admin?

      @orgs = Morphosource::UnlinkedOrganizationsSearchService.call(params)
    end

    # disable the bookmark control from displaying in gallery view
    # Hyrax doesn't show any of the default controls on the list view, so
    # this method is not called in that context.
    def render_bookmarks_control?
      false
    end

    private

    def set_default_view
      # Set the default view to 'list' if not specified in params
      request_params[:view] ||= params[:view] ||= 'list'
    end
  end
end
