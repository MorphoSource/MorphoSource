# Display remote file health for admin
module Morphosource
  module Admin
    class RemoteFileHealthsController < Morphosource::ItemtableController
      include MorphosourceHelper
      prepend_before_action :authorize_index, only: [:index]

      PAGE_TITLE = I18n.t("morphosource.admin.remote_file_health.page_title")
      PAGE_DESCRIPTION = I18n.t("morphosource.admin.remote_file_health.page_description")

      def index
        if RemoteFileHealth.count > 0
          @last_checked =  RemoteFileHealth.last.created_at.strftime("%A, %B %d, %Y at %I:%M %p")
        else
          @last_checked = "(none)"
        end
        super
      end

      def verify
        if current_user.admin?
          if active_jobs("RemoteFileVerificationJob").count > 0
            flash[:error] = "An existing system-wide remote file verification is running."
          else
            RemoteFileVerificationJob.perform_later
            flash[:notice] = "System-wide remote file verification has been started.  Please check this page later to see the updates."
          end          
        end
        redirect_to(main_app.remote_file_health_path) and return      
      end


def active_jobs(job_class)
  (queued_resque_jobs + working_resque_jobs).select { |j| j["job_class"] == job_class }
end

def queued_resque_jobs
  @queued_resque_jobs ||= begin
    Resque.data_store.queue_names
      .map { |n| Resque.data_store.everything_in_queue(n) }
      .flatten
      .map { |j| Resque.decode(j)["args"][0] || {} }  
  end
end

def working_resque_jobs
  @working_resque_jobs ||= begin
    Resque.workers
      .map { |w| w.job }
      .select { |j| j.present? }
      .map { |j| (j["payload"]["args"][0] || {}).merge(
        "run_at" => j["run_at"] 
      )}
  end
end




      
      private

      # Only admins can access this index route
      def authorize_index
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