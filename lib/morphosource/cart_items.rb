module Morphosource
  module CartItems
    include Morphosource::CartItems::RequestItems

    # Used for Item counts at top of page and for flash messages
    def item_count_text
      count_text(@items.count)
    end

    def count_text(count)
      count.to_s.concat(count == 1 ? " Item" : " Items")
    end

    # gets id(s) for either single button or batch
    def id_params
      params[:item_id] || params[:batch_document_ids] || params[:batch_download_ids]
    end

    # methods for works
    def work_already_in_cart?(work_id)
      work_ids_in_cart.include? work_id
    end

    def find_item_in_cart(work_id)
      items_in_cart.find{ |i| i.work_id == work_id }
    end

    def work_requested?(work_id)
      my_active_requests_work_ids.include? work_id
    end

    def work_in_cart_or_requested?(work_id)
      work_already_in_cart?(work_id) || work_requested?(work_id)
    end

    def requested_work_not_in_cart?(work_id)
      work_requested?(work_id) && !work_already_in_cart?(work_id)
    end

    def find_requested_item(work_id)
      my_active_requests.find{|item| item.work_id == work_id}
    end

    def usage
      @usage ||= begin
        if request.params['usage'].present?
          ActionController::Base.helpers.sanitize(request.params['usage'])
        else
          nil
        end
      end
    end

    def usage_list
      @usage_list ||= begin
        if request.params['usage_list'].present?
          @usage_list ||= ActionController::Base.helpers.sanitize(request.params['usage_list'])
        else
          nil
        end
      end
    end

    def create_downloaded_item(work_id)
      item = create_cart_item(work_id)
      item.update_attributes(in_cart: false, date_downloaded: Time.now, download_usage: usage, download_usage_list: usage_list) if item.present?
    end

    def downloadable_item_for_work?(work_id)
      cart_items.where(work_id: work_id).find{|item| item.downloadable? }.present?
    end

    def find_downloadable_item(work_id)
      cart_items.where(work_id: work_id).find{|item| item.downloadable? }
    end

    def create_cart_item(work_id)
      work = Media.find(work_id)
      if work.can_add_to_cart? || (current_user.can? :download, work.id)
        item = CartItem.create({user_id: current_user.ms_id, work_id: work.id, reviewers: work.reviewer})
      else
        item = nil
      end
      return item
    end

    def mark_as(action,items=@items,value: nil)
      items = Array(items)
      value = attribute_value(value)
      attribute = get_attribute(action)
       items.each do |item|
        item.date_cleared = nil
        item.send(attribute, value)
        item.action_by = current_user.ms_id if manager_action
        item.download_usage = usage if usage.present?
        item.download_usage_list = usage_list if usage_list.present?
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

    def manager_action
      self.class == Morphosource::My::RequestManagersController
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

    def access_control_ids_from_work_ids
      return [] unless @work_ids.present?
      solr_docs = ActiveFedora::SolrService.query(
        "*:*", 
        rows: 999999, 
        fq: ['has_model_ssim:Media', "id:(#{@work_ids.join(' OR ')})"], 
        fl: ['id', 'accessControl_ssim']
      )
      return solr_docs.map { |d| d['accessControl_ssim']&.first }.compact
    end

    def create_new_items(old_items,requested='requested')
      works = get_media_by_items(old_items)
      create_instance_variables_for_flash
      works.each do |work|
        unless work_in_cart_or_requested?(work.id)
          item = create_cart_item(work.id)
          if requested == 'requested'
            make_request(item)
          end
          @count += 1
        else
          if requested_work_not_in_cart?(work.id)
            @active_requests_moved << work.title[0]
          elsif work_already_in_cart?(work.id)
            @duplicates_in_cart << work.title[0]
          end
        end
      end
    end

    def create_instance_variables_for_flash
      @count = 0
      @duplicates_in_cart = []
      @active_requests_moved = []
    end

    def undownloadable(items)
      items.select{|item| !item.downloadable? }
    end

    delegate :downloaded_work_ids, :cart_items, :items_in_cart, :my_active_requests, :my_active_requests_work_ids, :requested_items, :previously_requested_items, :newly_requested_items, :requested_item_ids, :requested_items_work_ids, :my_cleared_requests_work_ids, :work_already_in_cart, to: :current_user
  end
end
