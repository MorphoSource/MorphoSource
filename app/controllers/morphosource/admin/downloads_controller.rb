# Display list of all downloads from all users for admin
module Morphosource
  module Admin
    class DownloadsController < Morphosource::ItemtableController
      before_action :require_permissions

      PAGE_TITLE = I18n.t("morphosource.dashboard.sidebar.admin_tools.content.all_downloads")

      def allowed_sort_parameters
        ['date_downloaded asc',
         'date_downloaded desc',
         'download_usage asc',
         'download_usage desc',
         'download_usage_list asc',
         'download_usage_list desc',
         'users.display_name asc',
         'users.display_name desc',
         'work_id asc',
         'work_id desc']
      end

      private

      def entry_name
        'download'
      end

      def require_permissions
        authorize! :read, :admin_dashboard
      end

      def get_items
        @items = CartItem.where("date_downloaded IS NOT NULL").includes(:user).order(sort_param)
      end

      def valid_sort_attributes
        ['date_downloaded', 'work_id', 'users.display_name', 'download_usage', 'download_usage_list']
      end

      def default_sort_param
        'date_downloaded DESC'
      end

      def valid_filter_attributes
        ['work_id', 'user_id', 'date_downloaded_after', 'date_downloaded_before']
      end

      def filter_attribute_where_statements
        {
          'date_downloaded_after' => 'date_downloaded >= ?',
          'date_downloaded_before' => 'date_downloaded <= ?'
        }
      end

      def prepare_items_for_csv
        prepare_cart_items_for_csv
      end
    end
  end
end