module Morphosource
  module My
    class BackgroundJobsController < Morphosource::ItemtableController
      PAGE_TITLE = I18n.t("morphosource.dashboard.my.background_jobs.page_title")
      PAGE_DESCRIPTION = I18n.t("morphosource.dashboard.my.background_jobs.page_description")

      private

      def get_items
        @items = current_user&.background_jobs&.order(sort_param) || []
      end

      def valid_sort_attributes
        ['job_id', 'created_at', 'updated_at']
      end

      def default_sort_param
        'created_at DESC'
      end

      def valid_filter_attributes
        ['job_id', 'job_class', 'created_after', 'created_before', 'updated_after', 'updated_before']
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
          item.attributes.except('created_objects').map do |field, value|
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