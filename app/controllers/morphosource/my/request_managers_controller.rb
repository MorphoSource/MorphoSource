module Morphosource
  module My
    class RequestManagersController < Hyrax::MyController
      include Morphosource::CartItems
      include Morphosource::CartItems::ListItems
      include Morphosource::CartItems::RequestManagerItems
      include Morphosource::CartItems::RequestItems
      include Morphosource::CartItems::RequestMessages
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
        send_response_messages(@items, 'approved')
        flash[:notice] = get_flash('approve')
        redirect_to main_app.request_manager_path
      end

      def clear_request
        mark_as('requested', value: 'nil')
        mark_as('cleared')
        send_response_messages(@items, 'cleared')
        flash[:notice] = get_flash('clear')
        redirect_to main_app.request_manager_path
      end

      def deny_download
        mark_as('denied')
        send_response_messages(@items, 'denied')
        flash[:notice] = get_flash('deny')
        redirect_to main_app.request_manager_path
      end

      def edit_expiration
        mark_as('expired', value: @date)
        flash[:notice] = get_flash('expiration')
        redirect_to main_app.previous_requests_path
      end

      def send_response_messages(items, action)
        if items.count == 1
          send_response_message(items.first, action)
        else
          send_batch_response_messages(items, action)
        end
      end

      def send_batch_response_messages(items, action)
        reviewer = current_user
        # send message for each requestor
        requestors = []
        requestor_items = {}
        items.each do |item|
          requestors << item.user_id
          requestor_items[item.user_id] = item # store the item for sending details if single item
        end
        requestor_counts = requestors.group_by{|e| e}.map{|k, v| [k, v.length]}.to_h
        requestor_counts.each do |requestor_id, count|
          requestor = User.where(ms_id: requestor_id).first
          if requestor.present?
            if count == 1
              send_response_message(requestor_items[requestor_id], action)
            else
              message_to_requestor = "<p>Your download request has been #{action} for #{count} media.</p>" +
              "<li><a href='http://#{host_name}/dashboard/my/cart'>View my media cart</a></li>" +
              "<li><a href='http://#{host_name}/dashboard/my/requests'>View my requests</a></li>" +
              "<p>Please contact <a href='mailto:#{reviewer.email}'>#{reviewer.name_or_email}</a> if you have a question related to this request.</p>" 
              deliver(email_sender, requestor, message_to_requestor, "Your download request has been #{action}")
            end
          end
        end
      end
      
      def send_response_message(item, action)
        work = Media.find(item.work_id)
        if work.present?          
          reviewer = current_user
          requestor = User.where(ms_id:item.user_id).first
          if requestor.present?
            message_to_requestor = "<p>Your download request has been #{action} for " + cart_item_message_content(item, work) + "</p>" +
            "<li><a href='http://#{host_name}/dashboard/my/cart'>View my media cart</a></li>" +
            "<li><a href='http://#{host_name}/dashboard/my/requests'>View my requests</a></li>" +
            "<p>Please contact <a href='mailto:#{reviewer.email}'>#{reviewer.name_or_email}</a> if you have a question related to this request.</p>" 
            deliver(email_sender, requestor, message_to_requestor, "Your download request has been #{action}")
          end
        end
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
