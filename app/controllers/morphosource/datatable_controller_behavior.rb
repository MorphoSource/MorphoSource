# Methods to quickly bootstrap controllers that use JS datatable to list Rails DB objects
module Morphosource
  module DatatableControllerBehavior
    def paginate_and_sort_items
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