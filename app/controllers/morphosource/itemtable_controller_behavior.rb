# Methods to quickly bootstrap controllers that use JS datatable to list Rails DB objects
module Morphosource
  module ItemtableControllerBehavior
    def sort_param
      if params[:sort].present?
        sort_attribute, order = params[:sort].split(' ')
        if sort_attribute.present? && valid_sort_attributes.include?(sort_attribute)
          if !order.present? || !['asc', 'desc'].include?(order)
            order = 'desc'
          end
          @sort_param = "#{sort_attribute} #{order.upcase}"
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

    # Override this in controller to provide different default sort
    def default_sort_param
      'id DESC'
    end

    def split_filter_user_keys
      if params.dig(:filter_items, :user_id).present? 
        params[:filter_items][:user_id] = params[:filter_items][:user_id].split(',')
      end
    end

    def filter_items
      (params[:filter_items] || []).each do |attribute, value|
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
  end
end