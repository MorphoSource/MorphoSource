module Morphosource
  module My
    class RequestManagersController < Hyrax::MyController
      include Morphosource::CartItems
      include Morphosource::CartItems::ListItems
      include Morphosource::CartItems::RequestManagerItems
      include Morphosource::CartItems::RequestItems
      with_themed_layout 'morphosource_dashboard'      

      before_action :get_items_by_id, only: [:clear_request, :approve_download, :deny_download, :edit_expiration]

      before_action :get_expiration_date, only: [:approve_download, :edit_expiration]

      def index
        get_items_for_tab
        render 'morphosource/my/request_manager/index'
      end

      def approve_download
        mark_as('approved')
        mark_as('expired', value: @date)
        flash[:notice] = get_flash('approve')
        redirect_to main_app.request_manager_path
      end

      def clear_request
        mark_as('requested', value: 'nil')
        mark_as('cleared')
        flash[:notice] = get_flash('clear')
        redirect_to main_app.request_manager_path
      end

      def deny_download
        mark_as('denied')
        flash[:notice] = get_flash('deny')
        redirect_to main_app.request_manager_path
      end

      def edit_expiration
        mark_as('expired', value: @date)
        flash[:notice] = get_flash('expiration')
        redirect_to main_app.previous_requests_path
      end

      private

        def previous_requests?
          request.fullpath.include? 'previous_requests'
        end

        def get_items_for_tab
          @tab = previous_requests? ? 'previous' : 'new'
          get_items(@tab)
          get_requesters(@tab)
        end

        def get_flash(action)
          case action
          when 'approve'
            "#{item_count_text} Approved for Download"
          when 'clear'
            "Request cleared for #{item_count_text}"
          when 'deny'
            "Download Denied"
          when 'expiration'
            "Expiration Date Updated"
          end
        end

        def get_expiration_date
          @date = params[:expiration_date]
        end

    end
  end
end
