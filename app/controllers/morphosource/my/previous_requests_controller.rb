module Morphosource
  module My
    class PreviousRequestsController < Morphosource::ItemtableController
      include Morphosource::CartItems

      before_action :authenticate_user!, :set_date_param_present

      PAGE_TITLE = I18n.t("morphosource.dashboard.my.previous_requests.page_title")
      PAGE_DESCRIPTION = I18n.t("morphosource.dashboard.my.previous_requests.page_description")

      # Controller-specific behavior

      def edit_expiration
        date = params[:expiration_date]
        unless date.present? && (DateTime.parse date rescue nil).present?
          flash[:error] = "Expiration date is missing"
          redirect_to main_app.previous_requests_path and return
        end

        get_items_by_id

        unless @items.present?
          flash[:error] = "No requests selected for edit expiration date"
          redirect_to main_app.previous_requests_path and return
        end

        unless current_user && @items.all? { |i| i.reviewers.include?(current_user.ms_id) }
          flash[:error] = "Not authorized to edit expiration date for one or more requests"
          redirect_to main_app.previous_requests_path and return
        end

        mark_as('expired', value: date)
        flash[:notice] = "Expiration Date Updated"
        redirect_to main_app.previous_requests_path
      end

      # Itemtable Methods

      def get_items
        @items = current_user ?
          CartItem
            .where(":id = ANY(reviewers)", id: current_user.ms_id).or(CartItem.where(action_by: current_user.ms_id))
            .where("date_approved IS NOT NULL OR date_cleared IS NOT NULL OR date_canceled IS NOT NULL OR date_denied IS NOT NULL OR date_expired < now()")
            .includes(:user)
            .joins("INNER JOIN users decision_users ON cart_items.action_by = decision_users.ms_id")
            .order(sort_param)
          : []
      end

      def valid_sort_attributes
        [
          'work_id',
          'users.display_name',
          'decision_users.display_name',
          'date_requested',
          'date_decided',
          'date_expired',
          'date_downloaded',
          'use'
        ]
      end

      def allowed_sort_parameters
        ['date_decided asc',
         'date_decided desc',
         'date_downloaded asc',
         'date_downloaded desc',
         'date_expired asc',
         'date_expired desc',
         'date_requested asc',
         'date_requested desc',
         'decision_users.display_name asc',
         'decision_users.display_name desc',
         'use asc',
         'use desc',
         'users.display_name asc',
         'users.display_name desc',
         'work_id asc',
         'work_id desc']
      end

      def custom_sort_params
        {
          'date_decided' => 'greatest(date_approved,date_denied,date_canceled,date_cleared)'
        }
      end

      def default_sort_param
        'date_requested DESC'
      end

      def user_key_params
        ['user_id', 'action_by']
      end

      def valid_filter_attributes
        [
          'work_id',
          'user_id',
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

      def date_params
        valid_filter_attributes - ['work_id', 'user_id']
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
        excluded_fields = [
          'id', 'created_at', 'updated_at', 'in_cart', 'download_hash', 'download_usage',
          'download_usage_list', 'download_attempts', 'download_method'
        ]
        @items = @items.map do |item|
          item.attributes.except(*excluded_fields).map do |field, value|
            if field == 'work_id'
              field = 'media_id'
            elsif field == 'user_id'
              field = 'download_user'
              value = User.find_by_user_key(value)&.name_and_email
            elsif field == 'action_by'
              field = 'decision_user'
              value = User.find_by_user_key(value)&.name_and_email
            elsif field == 'reviewers'
              field = 'current_reviewers'
              value = (value || []).map { |user_key| User.find_by_user_key(user_key)&.name_and_email }
            end

            if value.kind_of? Array
              value = value.join(';')
            end

            [field, value]
          end.to_h.merge({ 'download_user_id' => item&.user_id })
        end
      end

      private

      def set_date_param_present
        if search_form_present? && params[:filter_items].present? && ( date_params.any? { |date_param| params[:filter_items][date_param].present? } )
          @date_param_present = true
        end
      end
    end
  end
end