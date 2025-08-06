# Display remote file health for admin
module Morphosource
  module Admin
    class RemoteFileHealthsController < Morphosource::ItemtableController
      include MorphosourceHelper
      include Morphosource::ResqueJobsHelper
      prepend_before_action :authorize, only: [:index, :verify_all, :verify_media]

      PAGE_TITLE = I18n.t("morphosource.admin.remote_file_health.page_title")
      PAGE_DESCRIPTION = I18n.t("morphosource.admin.remote_file_health.page_description")

      # Blank out breadcrumbs from My::TeamsController
      def build_breadcrumbs; end
      
      def index
        if RemoteFileHealth.count > 0
          @last_checked =  RemoteFileHealth.last.created_at.strftime("%A, %B %d, %Y at %I:%M %p")
        else
          @last_checked = "(none)"
        end
        @disable_verify_button = active_jobs("RemoteFileVerificationJob").count > 0
        super
      end

      def verify_media
        media = Media.find(params[:id])
        media.set_remote_file_health
        flash[:notice] = "Remote file verification of media #{media.id} has been completed."    
        redirect_to(request.referrer || main_app.remote_file_health_path) and return      
      end

      def verify_all
        if active_jobs("RemoteFileVerificationJob").count > 0
          flash[:error] = "An existing system-wide remote file verification is running."
        else
          RemoteFileVerificationJob.perform_later
          flash[:notice] = "System-wide remote file verification has been started.  Please check this page later to see the updates."
        end          
        redirect_to(main_app.remote_file_health_path) and return      
      end

      
      private

      def authorize
        authorize! :manage, RemoteFileHealth
      end

      def get_items
        @items = RemoteFileHealth.where(status:'Problematic').order(sort_param)
      end

      def valid_sort_attributes
        ['media', 'status']
      end

      def default_sort_param
        'media ASC'
      end

      def valid_filter_attributes
        ['media', 'status']
      end

      def prepare_items_for_csv
        @items = @items.map do |item|
          media = solr_doc_find(item.media)
          org = solr_doc_find(media&.media_organization_id)
          team = solr_doc_find(org&.team_id)
          org_team = team.present? ? team.title.first : ""
          url = media&.remote_origin_url&.first
          {
            "media" => item.media,
            "org_team" => org_team,
            "url" => url,
            "issues" => item.details,
            "created_at" => item.created_at,
            "updated_at" => item.updated_at
          }
        end
      end
 
    end
  end
end