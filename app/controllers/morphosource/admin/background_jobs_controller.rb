# Display list of all background jobs from all users for admin
module Morphosource
  module Admin
    class BackgroundJobsController < Morphosource::ItemtableController
      helper_method :get_resque_data?
      # todo handle permissions outside of controller

      PAGE_TITLE = I18n.t("morphosource.admin.background_jobs.page_title")

      def index
        if get_resque_data?
          @all_resque_jobs = queued_resque_jobs + failed_resque_jobs + working_resque_jobs
        end
        super
      end

      private

      def get_items
        @items = BackgroundJob.includes(:user).all.order(sort_param)
      end

      def valid_sort_attributes
        ['job_id', 'created_at', 'updated_at', 'users.display_name']
      end

      def default_sort_param
        'created_at DESC'
      end

      def job_classes
        {
          "BatchSubmissionJobs::Ms2Batch::ControlJob" => "Batch Media Submission"
        }
      end
      helper_method :job_classes

      def get_resque_data?
        params[:resque].present? && params[:resque] == "true" 
      end

      def queued_resque_jobs
        @queued_resque_jobs ||= begin
          Resque.data_store.queue_names
            .map { |n| Resque.data_store.everything_in_queue(n) }
            .flatten
            .map { |j| Resque.decode(j)["args"][0] || {} }  
        end
      end

      def failed_resque_jobs
        @failed_resque_jobs ||= begin
          Resque::Failure.all(0, 999999)
            .map { |j| (j["payload"]["args"][0] || {}).merge(
              "exception" => j["exception"], 
              "error" => j["error"], 
              "failed_at" => j["failed_at"]
            )}  
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
    end
  end
end