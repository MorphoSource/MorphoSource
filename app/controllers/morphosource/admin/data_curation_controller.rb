module Morphosource
  module Admin
    class DataCurationController < ApplicationController
      include Morphosource::Breadcrumbs
      before_action :require_permissions
      with_themed_layout 'morphosource_dashboard'

      PAGE_TITLE = I18n.t("morphosource.dashboard.admin.data_curation.page_title")

      def apply_permission_template
        begin
          team = Collection.find(params[:team_id])
          Morphosource::DataCuration::OrganizationNormalizationService.call( team_id: params[:team_id],
                                                                             project_id: params[:project_id],
                                                                             old_manager_email: params[:old_manager_email],
                                                                             email: params[:email],
                                                                             remove_previous_reviewers: params[:remove_previous_reviewers],
                                                                             update_publication_status: params[:update_publication_status])
        rescue
          flash[:error] = 'One or more of the values entered are incorrect.'
          redirect_back(fallback_location: admin_data_curation_path) and return
        end
        flash[:notice] = 'Organization Normalization job has been submitted for background processing. Please check back later.'
        path = team.team? ? team_path(team) : organization_collection_path(team)
        redirect_to path
      end

      def add_breadcrumbs
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb t(:'morphosource.dashboard.sidebar.admin_tools.management.data_curation'), main_app.admin_data_curation_path
      end

      private

        def require_permissions
          authorize! :read, :admin_dashboard
        end

    end
  end
end
