# Display list of all background jobs from all users for admin
module Morphosource
  module Admin
    class BackgroundJobsController < Morphosource::ItemtableController
      prepend_before_action :authorize_index, only: [:index]

      helper_method :get_resque_data?

      PAGE_TITLE = I18n.t("morphosource.admin.background_jobs.page_title")
      PAGE_DESCRIPTION = I18n.t("morphosource.admin.background_jobs.page_description")

      def index
        if get_resque_data?
          @all_resque_jobs = queued_resque_jobs + failed_resque_jobs + working_resque_jobs
        end
        super
      end

      def allowed_sort_parameters
        ['created_at asc',
         'created_at desc',
         'job_id asc',
         'job_id desc',
         'updated_at asc',
         'updated_at desc',
         'users.display_name asc',
         'users.display_name desc']
      end

      private

      # Only admins can access this index route
      def authorize_index
        authorize! :manage, BackgroundJob
      end

      def get_items
        @items = BackgroundJob.includes(:user).all.order(sort_param)
      end

      def valid_sort_attributes
        ['job_id', 'created_after', 'updated_at', 'users.display_name']
      end

      def default_sort_param
        'created_at DESC'
      end

      def valid_filter_attributes
        ['job_id', 'user_id', 'job_class', 'created_after', 'created_before', 'updated_after', 'updated_before']
      end

      def filter_attribute_where_statements
        {
          'created_after' => 'created_at >= ?',
          'created_before' => 'created_at <= ?',
          'updated_after' => 'updated_at >= ?',
          'updated_before' => 'updated_at <= ?'
        }
      end

      def job_classes
        {
          "BatchSubmissionJobs::Ms2Batch::ControlJob" => "Batch Media Submission"
        }
      end
      helper_method :job_classes

      def prepare_items_for_csv
        @items = @items.map do |item|
          item.attributes.map do |field, value|
            if field == 'created_at'
              field = 'started_at'
            elsif field == 'user_id'
              value = User.find_by_user_key(value)&.name_and_email
            end

            if value.kind_of? Array
              value = value.join(';')
            end

            [field, value]
          end.to_h
        end
      end

      def get_resque_data?
        params[:resque].present? && params[:resque] == "true"
      end

      # Methods for getting resque jobs

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