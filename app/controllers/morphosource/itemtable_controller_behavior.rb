# Methods to quickly bootstrap controllers that use JS datatable to list Rails DB objects
module Morphosource
  module ItemtableControllerBehavior
    def paginate_and_sort_items
      @items = @items.page(page_param).per(row_param)
    end

    def page_param
      params[:page] ||= 1
    end

    def row_param
      params[:rows] ||= Hyrax.config.teams_show_work_item_rows
    end

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

    def valid_sort_attributes
      ['id']
    end

    def default_sort_param
      'id DESC'
    end
  end
end