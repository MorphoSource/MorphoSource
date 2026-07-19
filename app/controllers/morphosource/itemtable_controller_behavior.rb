# Methods to quickly bootstrap controllers that use JS datatable to list Rails DB objects
module Morphosource
  module ItemtableControllerBehavior
    extend ActiveSupport::Concern

    included do
      helper_method :entry_name, :empty_state_message
    end

    # Record name used for "No X found" / "Displaying X 1 - 20 of 42" pagination text (see
    # morphosource/itemtable/_document_list and _results_pagination, both shared by every
    # controller that includes this module, whether or not it inherits from ItemtableController).
    # Override in a controller or concern; nil falls back to Kaminari's default (humanized model
    # name).
    def entry_name
      nil
    end

    # Overridable message shown in the empty-state block (see morphosource/itemtable/_document_list)
    # in place of the generic "No <entry_name(s)> found." text. nil (the default) falls back to
    # that generic message.
    def empty_state_message
      nil
    end

    # For custom param names, method returns real DB ordering clause and @sort_param is custom name
    def sort_param
      if params[:sort].present?
        sort_attribute, order = params[:sort].split(' ')
        if sort_attribute.present? && valid_sort_attributes.include?(sort_attribute)
          if !order.present? || !['asc', 'desc'].include?(order)
            order = 'desc'
          end
          if custom_sort_params.key?(sort_attribute)
            # special case for custom param names
            @sort_param = "#{sort_attribute} #{order.upcase}"
            return "#{custom_sort_params[sort_attribute]} #{order.upcase}"
          else
            @sort_param = "#{sort_attribute} #{order.upcase}"
          end
          
        else
          @sort_param = default_sort_param
        end
      else
        @sort_param = default_sort_param
      end
    end

    # Override this in controller to provide additional valid attributes
    def valid_sort_attributes
      ['id']
    end

    # Override this in controller to provide custom sort param names
    def custom_sort_params
      {}
    end

    # Override this in controller to provide different default sort
    def default_sort_param
      'id DESC'
    end

    def user_key_params
      ['user_id']
    end

    def split_filter_user_keys
      user_key_params.each do |user_key_param|
        if params.dig(:filter_items, user_key_param).present? 
          next if params.dig(:filter_items, user_key_param).kind_of? Array
          params[:filter_items][user_key_param] = params[:filter_items][user_key_param].split(',')
        end
      end
    end

    def filter_items
      (params[:filter_items] || []).each do |attribute, value|
        if value.kind_of?(Array)
          value = value.compact.map(&:strip)
        else
          value = value.strip
        end
        next unless valid_filter_attributes.include?(attribute) && value.present?
        instance_variable_set("@#{attribute}", value)
        if filter_attribute_where_statements.key?(attribute)
          @items = @items.where(filter_attribute_where_statements[attribute], value)
        else
          @items = @items.where(attribute => value)
        end
      end
    end

    # Override this in controller to provide valid attributes
    def valid_filter_attributes
      []
    end

    # Override this in controller to provide custom where formula statements for attribute values
    def filter_attribute_where_statements
      {}
    end

    def paginate_items
      return if request.format == 'csv'
      @items = @items.page(page_param).per(row_param)
    end

    def page_param
      params[:page] ||= 1
    end

    def row_param
      params[:rows] ||= Hyrax.config.teams_show_work_item_rows
    end

    # Utility method to prepare CartItem records for csv
    def prepare_cart_items_for_csv
      @items = @items.map do |item|
        item.attributes.except('id', 'download_hash', 'in_cart').map do |field, value|
          if field == 'work_id'
            field = 'media_id'
          elsif field == 'user_id' || field == 'action_by'
            value = User.find_by_user_key(value)&.name_and_email
          elsif field == 'reviewers'
            value = (value || []).map { |user_key| User.find_by_user_key(user_key)&.name_and_email } 
          end

          if value.kind_of? Array
            value = value.join(';')
          end

          [field, value]
        end.to_h
      end
    end
  end
end