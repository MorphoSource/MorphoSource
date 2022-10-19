# Display list of all downloads from all users for admin
module Morphosource
  module Admin
    class DownloadsController < Morphosource::ItemtableController
      before_action :require_permissions

      PAGE_TITLE = I18n.t("hyrax.admin.sidebar.all_downloads")

      private

      def require_permissions
        authorize! :read, :admin_dashboard
      end

      def get_items
        @items = CartItem.where("date_downloaded IS NOT NULL").includes(:user).order(sort_param)
      end

      def valid_sort_attributes
        ['date_downloaded', 'work_id', 'users.display_name']
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
        @items = @items.map { |i| i.attributes }
      end
    end
  end
end