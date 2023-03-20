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
          Morphosource::DataCuration::OrganizationNormalizationService.call(team_id: params[:team_id], collection_id: params[:collection_id], old_manager_email: params[:old_manager_email], email: params[:email], remove_previous_reviewers: params[:remove_previous_reviewers], update_publication_status: params[:update_publication_status])
        rescue
          flash[:error] = 'One or more of the values entered are incorrect.'
          redirect_back(fallback_location: admin_data_curation_path) and return
        end
        flash[:notice] = 'Organization Normalization job has been submitted for background processing. Please check back later.'
        redirect_to team_path(team)
      end

      private

        def require_permissions
          authorize! :read, :admin_dashboard
        end

    end
  end
end
