module Morphosource
  module My
    class RequestsController < Hyrax::MyController
      include Morphosource::CartItems
      include Morphosource::CartItems::ListItems

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
        flash[:notice] = item_count_text.concat(' Requested')
        redirect_back(fallback_location: my_requests_path)
      end

      def request_again
        re_request(@items)
        redirect_back(fallback_location: my_requests_path)
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
        redirect_back(fallback_location: my_requests_path)
      end
    end
  end
end
