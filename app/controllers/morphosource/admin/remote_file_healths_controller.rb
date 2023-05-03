# Display remote file health for admin
module Morphosource
  module Admin
    class RemoteFileHealthsController < Morphosource::ItemtableController
#      prepend_before_action :authorize_index, only: [:index]
#
#      helper_method :get_resque_data?

      PAGE_TITLE = I18n.t("morphosource.admin.remote_file_health.page_title")
      PAGE_DESCRIPTION = I18n.t("morphosource.admin.remote_file_health.page_description")

      def index
        super
      end

      private

      # Only admins can access this index route
      def authorize_index
        authorize! :manage, BackgroundJob
      end

      def get_items
#        @items = BackgroundJob.includes(:user).all.order(sort_param)
        @items = RemoteFileHealth.all
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

 
 
    end
  end
end