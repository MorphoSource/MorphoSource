# Display list of all downloads from all users for admin
module Morphosource
  class ItemtableController < ApplicationController
    include Morphosource::ItemtableControllerBehavior
    include Morphosource::ItemtableHelper
    
    before_action :get_items, only: [:index]
    before_action :split_filter_user_keys, only: [:index]
    before_action :filter_items, only: [:index]
    before_action :paginate_items, only: [:index]

    with_themed_layout 'morphosource_dashboard'

    PAGE_TITLE = nil # Overwrite in controller

    def index
      @search = true if ( params[:search].present? || params[:commit] == 'Search' )

      respond_to do |format|
        format.html do 
          @item_count = @items.total_count
        end
        format.csv  do
          prepare_items_for_csv
        end
      end
    end

    private

    def page_title
      self.class::PAGE_TITLE
    end
    helper_method :page_title
  end
end