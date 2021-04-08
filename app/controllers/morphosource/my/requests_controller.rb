module Morphosource
  module My
    class RequestsController < Hyrax::MyController
      include Morphosource::CartItems
      include Morphosource::CartItems::ListItems
      with_themed_layout 'morphosource_dashboard'      

      before_action :get_items_by_id, except: [:index]
      before_action :get_intended_use, only: [:request_item, :request_again, :request_work]

      def index
        get_items('my_requests')
        render 'morphosource/my/requests/index'
      end

      def request_item
        @items = undownloadable(@items)
byebug
        re_request(inactive(@items)) unless inactive(@items).empty?
byebug
        make_request(unrequested(@items)) unless unrequested(@items).empty?
byebug
#        send_request_messages(@items)
        flash[:notice] = item_count_text.concat(' Requested')
        redirect_back(fallback_location: my_requests_path)
      end

      def request_again
        re_request(@items)
byebug
send_request_messages(@items)
        redirect_back(fallback_location: my_requests_path)
      end

      def send_request_messages(items)
        requestor = current_user

        # send message for each reviewer
        reviewers = []
        items.each do |item|
          reviewers << item.reviewer
        end


        content =  items.count.to_s + " media "
        content += " for intended use: <i>" + items.first.use + "</i>.  " 

        message_to_reviewer = "<a href='mailto:#{requestor.email}'>#{requestor.name_or_email}</a> has requested to download " + content + "Please review in <a href='http://#{Hyrax.config.host_name}/dashboard/my/request_manager'>Manage Requests</a> page." 
        Hyrax::MessengerService.deliver(::User.batch_user, reviewer, message_to_reviewer, "You have download request to review")
        
        message_to_requestor = "You have sent a download request to <a href='mailto:#{reviewer.email}'>#{reviewer.name_or_email}</a> for downloading " + content + "You can manage your requests in <a href='http://#{Hyrax.config.host_name}/dashboard/my/requests'>My Requests</a> page." 
        Hyrax::MessengerService.deliver(::User.batch_user, requestor, message_to_requestor, "You have sent a download request")

      end
      
      def send_request_message(item, work)
        requestor = current_user
        reviewer = User.find(work.reviewer).first
        content = "the media <b>" + work.title.first + "</b>"
        content += " of " + work.physical_object_type + " <b>" + work.object_title + "</b>" if work.object_title.present?
        content += " for intended use: <i>" + item.use + "</i>.  " 

        message_to_reviewer = "<a href='mailto:#{requestor.email}'>#{requestor.name_or_email}</a> has requested to download " + content + "Please review in <a href='http://#{Hyrax.config.host_name}/dashboard/my/request_manager'>Manage Requests</a> page." 
        Hyrax::MessengerService.deliver(::User.batch_user, reviewer, message_to_reviewer, "You have download request to review")
        
        message_to_requestor = "You have sent a download request to <a href='mailto:#{reviewer.email}'>#{reviewer.name_or_email}</a> for downloading " + content + "You can manage your requests in <a href='http://#{Hyrax.config.host_name}/dashboard/my/requests'>My Requests</a> page." 
        Hyrax::MessengerService.deliver(::User.batch_user, requestor, message_to_requestor, "You have sent a download request")

        # arguments passed to messenger_service: (sender, recipients, body, subject, *args)
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
            create_new_requested_item(work_id)
          end
        else
          flash[:alert] = 'You are not authorized to request this work.'
        end
        send_request_message(item, work)
        redirect_back(fallback_location: my_requests_path)
      end
    end
  end
end
