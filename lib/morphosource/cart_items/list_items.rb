module Morphosource
  module CartItems
    module ListItems

      # Used by #index for all cart item views

      def get_items(page)
        @items = items(page)
        @solr_docs = solr_docs(page)
        @item_count = item_count(page)
      end

      def get_restricted_items
        @unrestricted_items = downloadable_items
        @restricted_items = undownloadable_items
        @restricted_count = count_text(@restricted_items.count)
      end

      @@page_items = {
        'cart' => {
          item_ids: :item_ids_in_cart,
          order: 'created_at DESC',
          work_ids: :work_ids_in_cart,
        },
        'downloads' => {
          item_ids: :downloaded_items,
          order: 'date_downloaded DESC',
          work_ids: :uniq_downloaded_work_ids
        },
        'my_requests' => {
          item_ids: :my_requests_ids,
          order: 'created_at DESC',
          work_ids: :my_requests_work_ids
        },
        'request_manager' => {
          item_ids: :newly_requested_item_ids,
          order: "user_id DESC",
          work_ids: :newly_requested_items_work_ids,
          user_ids: :newly_requested_items_user_ids
        },
        'previous_requests' => {
          item_ids: :previously_requested_item_ids,
          order: 'date_requested DESC',
          work_ids: :previously_requested_items_work_ids,
          user_ids: :previously_requested_items_user_ids
        }
      }

      def items(page)
        ids = get_value(page,:item_ids)
        order = get_order(page)
        if page == 'request_manager'
          new_request_items(ids)
        else
          CartItem.where(id: ids).order(order).page params[:page]
        end
      end

      # Using instead of search in order to get back full results instead of paginated
      def solr_docs(page)
        work_ids = get_value(page,:work_ids)
        work_ids.each_with_object([]){|id, docs| docs << SolrDocument.find(id)}
      end

      def item_count(page)
        count = get_value(page,:item_ids).count
        count_text(count)
      end

      def downloadable_items
        items_in_cart.select{ |item| (item.downloadable? || user_is_approver?(item)) }
      end

      def undownloadable_items
        items_in_cart.select{ |item| (!item.downloadable? && !user_is_approver?(item)) }
      end

      def uniq_downloaded_work_ids
        downloaded_work_ids.uniq
      end

      def new_request_items(ids)
        CartItem.where(id: ids).order("user_id desc").order("use desc")
      end

      def get_requesters(page)
        ids = get_value(page,:user_ids).uniq
        User.where(id: ids).page params[:page]
      end

      def get_value(page,key)
        self.method(@@page_items[page][key]).()
      end

      def get_order(page)
        @@page_items[page][:order]
      end

      delegate :item_ids_in_cart, :work_ids_in_cart, :downloaded_items, :my_requests_ids, :my_requests_work_ids, :newly_requested_item_ids, :newly_requested_items_work_ids, :newly_requested_items_user_ids, :previously_requested_item_ids, :previously_requested_items_work_ids, :previously_requested_items_user_ids, to: :current_user
    end
  end
end
