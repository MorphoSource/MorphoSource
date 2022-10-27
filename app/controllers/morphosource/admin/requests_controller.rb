# Display list of all media download requests from all users for admin
module Morphosource
  module Admin
    class RequestsController < Morphosource::ItemtableController
      before_action :require_permissions

      PAGE_TITLE = I18n.t("hyrax.admin.sidebar.all_requests")

      private

      def require_permissions
        authorize! :read, :admin_dashboard
      end

      def get_items
        @items = CartItem.where.not(date_requested: nil).includes(:user).order(sort_param)
      end

      def valid_sort_attributes
        [
          'work_id', 
          'users.display_name',
          'reviewers',
          'date_requested', 
          'date_approved',
          'date_denied',
          'date_canceled',
          'date_expired',
          'date_cleared',
          'date_downloaded',
          'use'
        ]
      end

      def default_sort_param
        'date_requested DESC'
      end

      def user_key_params
        ['user_id', 'reviewers']
      end

      def valid_filter_attributes
        [
          'work_id', 
          'user_id',
          'reviewers',
          'date_requested_start', 
          'date_requested_end', 
          'date_approved_start',
          'date_approved_end',
          'date_denied_start',
          'date_denied_end',
          'date_canceled_start',
          'date_canceled_end',
          'date_expired_start',
          'date_expired_end',
          'date_cleared_start',
          'date_cleared_end',
          'date_downloaded_start',
          'date_downloaded_end'
        ]
      end

      def filter_attribute_where_statements
        {
          'date_requested_start' => 'date_requested >= ?',
          'date_requested_end' => 'date_requested <= ?',
          'date_approved_start' => 'date_approved >= ?',
          'date_approved_end' => 'date_approved <= ?',
          'date_denied_start' => 'date_denied >= ?',
          'date_denied_end' => 'date_denied <= ?',
          'date_canceled_start' => 'date_canceled >= ?',
          'date_canceled_end' => 'date_canceled <= ?',
          'date_expired_start' => 'date_expired >= ?',
          'date_expired_end' => 'date_expired <= ?',
          'date_cleared_start' => 'date_cleared >= ?',
          'date_cleared_end' => 'date_cleared <= ?',
          'date_downloaded_start' => 'date_downloaded >= ?',
          'date_downloaded_end' => 'date_downloaded <= ?',
        }
      end

      def prepare_items_for_csv
        prepare_cart_items_for_csv
      end
    end
  end
end