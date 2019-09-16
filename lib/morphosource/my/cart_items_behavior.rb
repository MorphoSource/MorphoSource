module Morphosource
  module My
    module CartItemsBehavior

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

      def file_restricted?(accessibility)
        accessibility == "restricted_download"
      end

      def items(page)
        ids = get_value(page,:item_ids)
        order = get_order(page)
        if page == 'request_manager'
          new_request_items(ids)
        else
          CartItem.where(id: ids).order(order).page params[:page]
        end
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

      def item_count(page)
        count = get_value(page,:item_ids).count
        count_text(count)
      end

      def count_text(count)
        count.to_s.concat(count == 1 ? " Item" : " Items")
      end

      def item_count_text
        count_text(@items.count)
      end

      def id_params
        params[:item_id] || params[:batch_document_ids]
      end

      def get_intended_use
        @intended_use = params[:intended_use].first
      end

      # Using instead of search in order to get back full results instead of paginated
      def solr_docs(page)
        work_ids = get_value(page,:work_ids)
        work_ids.each_with_object([]){|id, docs| docs << SolrDocument.find(id)}
      end

      def work_already_in_cart?(id)
        work_ids_in_cart.include? id
      end

      def mark_as(action,items=@items,value: nil)
        items = Array(items)
        value = attribute_value(value)
        attribute = get_attribute(action)
         items.each do |item|
          item.date_cleared = nil if item.date_cleared
          item.send(attribute, value)
          item.save
        end
      end

      def get_attribute(action)
        return 'use=' if action == 'use'
        return 'in_cart=' if action == 'in_cart'
        'date_'.concat(action).concat('=')
      end

      def attribute_value(value)
        case value
        when nil
          Time.now
        when 'nil'
          nil
        else
          value
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

      def get_items_by_id(ids=id_params)
        @items ||= CartItem.where(id: ids)
      end

      def get_media_by_items(items)
        get_work_ids_by_items(items)
        Media.where(id: @work_ids)
      end

      def get_work_ids_by_items(items=@items)
        items = Array(items)
        @work_ids = items.map{|item| item.work_id}
      end

      def create_new_items(old_items,requested='requested')
        value = requested == 'requested' ? Time.now : nil
        works = get_media_by_items(old_items)
        @count = 0
        @duplicates_in_cart = []
        @active_requests_moved = []
        works.each do |work|
          unless work_in_cart_or_requested?(work.id)
            item = create_cart_item(work.id)
            if user_is_approver?(item)
              unrestrict(item)
            elsif requested == 'requested'
              mark_as('requested',item,value: value)
              mark_as('use',item,value: @intended_use)
            end
            @count += 1
          else
            if work_requested?(work.id) && !work_already_in_cart?(work.id)
              @active_requests_moved << work.title[0]
            elsif work_already_in_cart?(work.id)
              @duplicates_in_cart << work.title[0]
            end
          end
        end
      end

      def create_downloaded_item(work_id)
        item = create_cart_item(work_id)
        mark_as('in_cart',item,value: false)
        mark_as('downloaded',item)
      end

      def work_in_cart_or_requested?(work_id)
        work_already_in_cart?(work_id) || work_requested?(work_id)
      end

      def downloadable_item_for_work?(work_id)
        downloadable_item_work_ids.include?(work_id)
      end

      def work_requested?(work_id)
        my_active_requests_work_ids.include?(work_id)
      end

      def find_requested_item(work_id)
        my_active_requests.find{|item| item.work_id == work_id}
      end

      def find_downloadable_item(work_id)
        current_user.cart_items.find{|item| item.downloadable? && item.work_id == work_id}
      end

      def create_cart_item(work_id)
        work = Media.find(work_id)
        CartItem.create({:user_id => current_user.id, :work_id => work.id, :restricted => work.restricted?, :approver => work.depositor})
      end

      def uniq_downloaded_work_ids
        downloaded_work_ids.uniq
      end

      def downloadable_items
        items_in_cart.select{ |item| (item.downloadable? || user_is_approver?(item)) }
      end

      def undownloadable_items
        items_in_cart.select{ |item| (!item.downloadable? && !user_is_approver?(item)) }
      end

      def user_is_depositor?(work)
        current_user.email == work.depositor
      end

      def user_is_approver?(item)
        current_user.email == item.approver
      end

      def unrestrict(item)
        item.restricted = false
        item.save
      end

      delegate :downloaded_work_ids, :downloaded_items, :items_in_cart, :item_ids_in_cart, :my_requests_ids, :my_requests_work_ids, :my_active_requests, :my_active_requests_work_ids, :requested_items, :previously_requested_items, :newly_requested_items, :requested_item_ids, :previously_requested_item_ids, :newly_requested_item_ids, :requested_items_work_ids, :previously_requested_items_work_ids, :newly_requested_items_work_ids, :work_ids_in_cart,  :newly_requested_items_user_ids, :previously_requested_items_user_ids, :downloadable_item_work_ids, to: :current_user
    end
  end
end
