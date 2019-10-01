module Morphosource
  module CartItems
    module RequestItems

      def get_intended_use
        @intended_use = params[:intended_use].first
      end

      def create_new_requested_item(work_id)
        item = create_cart_item(work_id)
        make_request(item)
      end

      def make_request(items)
        items = Array(items)
        items.each do |item|
          item.update_attributes(date_cleared: nil, date_requested: Time.now, use: @intended_use)
        end
      end

      def re_request(items)
        mark_as('in_cart',items,value: false)
        create_new_items(items)
      end

      def requested(items)
        items.select{|item| item.date_requested }
      end

      # For restricted items, returns those w/ request_status ("Not Requested", "Cleared")
      def unrequested(items)
        items.select{|item| !item.date_requested }
      end

      # For restricted items, returns those w/ request_status ("Expired","Denied","Canceled")
      def inactive(items)
        items.select{|item| item.inactive_request? }
      end

    end
  end
end
