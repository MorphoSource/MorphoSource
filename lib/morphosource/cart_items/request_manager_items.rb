module Morphosource
  module CartItems
    module RequestManagerItems

      include Morphosource::CartItems
      include Morphosource::CartItems::RequestItems

      def get_new_items
        @items = new_items
        @solr_docs = new_docs
        @item_count = new_item_count
        @requesters = get_new_requesters
      end

      def get_previous_items
        @items = previous_items
        @solr_docs = previous_docs
        @item_count = previous_item_count
        @requesters = get_previous_requesters
      end

      def new_items
        CartItem.where(id: new_requests_ids).order("user_id desc").order("use desc").page params[:page]
      end

      def previous_items
        order = 'date_requested DESC'
        CartItem.where(id: previously_requested_item_ids).order('date_requested DESC').page params[:page]
      end

      def requests
        @requests ||= current_user.requests
      end

      def new_requests
        @new_requests ||= requests.select{ |item| item.request_status == "Requested" }
      end

      def previous_requests
        @previous_requests ||= current_user.previous_requests
      end

      def new_requests_ids
        new_requests.map(&:id)
      end

      def previously_requested_item_ids
        previous_requests.map(&:id)
      end

      def new_docs
        work_ids = new_requests_work_ids
        # TODO: ??
        work_ids.each_with_object([]){|id, docs| docs << SolrDocument.find(id)}
      end

      def previous_docs
        work_ids = previous_requests_work_ids
        # TODO: ??
        work_ids.each_with_object([]){|id, docs| docs << SolrDocument.find(id)}
      end

      def new_item_count
        count = new_requests.size
        count_text(count)
      end

      def previous_item_count
        count = previous_requests.size
        count_text(count)
      end

      def new_requests_work_ids
        new_requests.map(&:work_id)
      end

      def previous_requests_work_ids
        previous_requests.map(&:work_id)
      end

      def get_new_requesters
        ids = new_requests_user_ids
        User.where(ms_id: ids).page params[:page]
      end

      def get_previous_requesters
        ids = previous_requests_user_ids
        User.where(ms_id: ids).page params[:page]
      end

      def new_requests_user_ids
        new_requests.map(&:user_id)
      end

      def previous_requests_user_ids
        previous_requests.map(&:user_id)
      end
    end
  end
end
