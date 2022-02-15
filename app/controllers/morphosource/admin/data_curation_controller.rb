module Morphosource
  module Admin
    class DataCurationController < ApplicationController
      before_action :require_permissions
      with_themed_layout 'morphosource_dashboard'

      def index
      end

      def apply_permission_template
        begin
          team = Collection.find(params[:team_id])
          Morphosource::DataCuration::OrganizationNormalizationService.call(team_id: params[:team_id], project_id: params[:project_id], email: params[:email], update_publication_status: params[:update_publication_status])
        rescue
          flash[:error] = 'One or more of the values entered are incorrect.'
          redirect_back(fallback_location: admin_data_curation_path) and return
        end
        flash[:notice] = 'Organization Normalization job has been submitted for background processing. Please check back later.'
        redirect_to team_media_path(team)
      end

      private

        def require_permissions
          authorize! :read, :admin_dashboard
        end

    end
  end
end
