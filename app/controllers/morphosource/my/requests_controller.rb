module Morphosource
  module My
    class RequestsController < Hyrax::MyController
      include Morphosource::CartItems
      include Morphosource::CartItems::ListItems
      include Morphosource::CartItems::RequestMessages
      with_themed_layout 'morphosource_dashboard'      

      before_action :get_items_by_id, except: [:index]
      before_action :get_intended_use, only: [:request_item, :request_again, :request_work]

      def index
        get_items('my_requests')
        render 'morphosource/my/requests/index'
      end

      def request_item
        @items = undownloadable(@items)
        re_request(inactive(@items)) unless inactive(@items).empty?
        make_request(unrequested(@items)) unless unrequested(@items).empty?
        send_request_messages(@items)
        flash[:notice] = item_count_text.concat(' Requested')
        redirect_back(fallback_location: my_requests_path)
      end

      def request_again
        re_request(@items)
        send_request_messages(@items)
        flash[:notice] = item_count_text.concat(' Requested')
        redirect_back(fallback_location: my_requests_path)
      end

      def send_request_messages(items)
        if items.count == 1
          send_request_message(items.first)
        else
          send_batch_request_messages(items)
        end
      end

      def send_batch_request_messages(items)
        requestor = current_user
        # send message for each reviewer
        reviewers = []
        items.each do |item|
          work = Media.find(item.work_id)
          if work.present?
            reviewer_id = work.reviewer.first
            reviewers << reviewer_id
          end
        end
        reviewer_counts = reviewers.group_by{|e| e}.map{|k, v| [k, v.length]}.to_h
        reviewer_counts.each do |reviewer_id, count|
          reviewer = User.where(ms_id: reviewer_id).first
          if reviewer.present?
            message_to_reviewer = "<a href='mailto:#{requestor.email}'>#{requestor.name_or_email}</a> has requested to download " + count.to_s + " media.  Please review this request in your <a href='http://#{host_name}/dashboard/my/request_manager'>Manage Requests</a> dashboard."
            deliver(email_sender, reviewer, message_to_reviewer, "You have download request to review")

            message_to_requestor = "You have sent a download request to <a href='mailto:#{reviewer.email}'>#{reviewer.name_or_email}</a> for downloading " + count.to_s + " media.  You can view pending requests in your <a href='http://#{host_name}/dashboard/my/requests'>My Requests</a> dashboard."
            deliver(email_sender, requestor, message_to_requestor, "You have sent a download request")
          end
        end
      end
      
      def send_request_message(item)
        work = Media.find(item.work_id)
        if work.present?
          requestor = current_user
          reviewer = User.where(ms_id:work.reviewer.first).first
          if reviewer.present?
            message_to_reviewer = "<a href='mailto:#{requestor.email}'>#{requestor.name_or_email}</a> has requested to download " + cart_item_message_content(item, work) + "Please review this request in your <a href='http://#{host_name}/dashboard/my/request_manager'>Manage Requests</a> dashboard."
            deliver(email_sender, reviewer, message_to_reviewer, "You have a download request to review")

            message_to_requestor = "You have sent a download request to <a href='mailto:#{reviewer.email}'>#{reviewer.name_or_email}</a> for downloading " + cart_item_message_content(item, work) + "You can view pending requests in your <a href='http://#{host_name}/dashboard/my/requests'>My Requests</a> dashboard."
            deliver(email_sender, requestor, message_to_requestor, "You have sent a download request")
          end
        end
      end

      def cancel_request
        mark_as('canceled')
        flash[:notice] = "Request Canceled"
        redirect_back(fallback_location: my_requests_path)
      end

      def move_to_cart
        mark_as('in_cart',value: true)
        flash[:notice] = "Item Moved to Cart"
        redirect_back(fallback_location: my_requests_path)
      end

      # Request download from media showcase page
      def request_work
        work_id = params[:work_id].first
        work = Media.find(work_id)
        if work.can_add_to_cart? || (current_user.can? :download, work.id)
          if work_already_in_cart?(work_id)
            item = find_item_in_cart(work_id)
            if item.unrequested? || item.cleared?
              make_request(item)
            else
              re_request(item)
            end
          # if a cleared request has been removed from the cart
          elsif my_cleared_requests_work_ids.include?(work_id)
            make_request(item)
          else
            item = create_new_requested_item(work_id)
          end
          send_request_message(item)
        else
          flash[:alert] = 'You are not authorized to request this work.'
        end
        redirect_back(fallback_location: my_requests_path)
      end
    end
  end
end
