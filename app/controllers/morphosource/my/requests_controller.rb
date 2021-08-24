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
        requestor = current_user
        # get a list of reviewer id => item, e.g.
        #   reviewer 1 => item 1, item 2
        #   reviewer 12 => item 1
        #   reviewer 23 => item 2
        # then send message for each reviewer
        items_reviewers = []
        reviewer_items = {}
        items.each do |item|
          item.reviewers.each do |r_id|
            (reviewer_items[r_id] ||= []) << item # store the item for sending details
          end
        end
        reviewer_items.each do |reviewer_id, items|
          send_request_message_to_reviewer(reviewer_id, items)
        end
        send_request_message_to_requestor(items)        
      end

      def send_request_message_to_requestor(items)
        requestor = current_user
        message_to_requestor = "<p>You have sent a request to download"
        if items.count <= max_for_details
          message_to_requestor += " the following media:" + 
          cart_item_message_content(items, "requestor")
        else
          message_to_requestor += " #{items.count} media. Since more than #{max_for_details} media have been requested, the individual media are not detailed in this message. "
        end  
        message_to_requestor += "<p>You can view pending requests in your <a href='http://#{host_name}/dashboard/my/requests'>My Requests</a> dashboard.</p>"
        deliver(email_sender, requestor, message_to_requestor, "You have sent a download request")
      end
      
      def send_request_message_to_reviewer(reviewer_id, items)
        # note: this method sends message to only 1 requestor and should be used in item.reviewers.each
        requestor = current_user
        reviewer = User.where(ms_id: reviewer_id).first

        message_to_reviewer = "<p>#{user_email_link(requestor)} has requested to download"
        if items.count <= max_for_details
          message_to_reviewer += " the following media:</p>" +
            cart_item_message_content(items, "reviewer") 
        else
          message_to_reviewer += " #{items.count} media. Since more than #{max_for_details} media have been requested, the individual media are not detailed in this message. "
        end
        message_to_reviewer += "<p>Please review this request in your <a href='http://#{host_name}/dashboard/my/request_manager'>Manage Requests</a> dashboard.</p>"
        deliver(email_sender, reviewer, message_to_reviewer, "You have a download request to review")
      end

      def send_requestor_action_message(item, action)
        work = Media.find(item.work_id)
        if work.present?          
          requestor = current_user
          reviewer_list = []
          item.reviewers.each do |r_id|
            reviewer_list << User.where(ms_id: r_id).first
          end
          message_to_reviewer = "<p>User #{user_email_link(requestor)} has #{action} the download request for: " + 
            cart_item_message_content([item], "reviewer") + "</p>"
          if action == 'canceled'
            message_to_reviewer += "<p>The request has been removed from your <a href='http://#{host_name}/dashboard/my/request_manager'>Manage Requests</a> dashboard.  You can view canceled requests in your <a href='http://#{host_name}/dashboard/my/previous_requests'>Previous Requests</a> page.</p>"
          end
          "<p>Please contact #{user_email_link(requestor)} if you have a question related to this request.</p>" 
          deliver(email_sender, reviewer_list, message_to_reviewer, "User has #{action} a download request")
        end
      end

      def cancel_request
        send_requestor_action_message(@items.first, 'canceled')
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
          send_request_messages([item])
        else
          flash[:alert] = 'You are not authorized to request this work.'
        end
        redirect_back(fallback_location: my_requests_path)
      end
    end
  end
end
