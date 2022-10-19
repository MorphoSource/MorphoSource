# Display list of all downloads from all users for admin
module Morphosource
  class ItemtableController < ApplicationController
    include Morphosource::ItemtableControllerBehavior
    include Morphosource::ItemtableHelper
    
    before_action :get_items, only: [:index, :search]
    before_action :split_filter_user_keys, only: [:search]
    before_action :filter_items, only: [:search]
    before_action :paginate_items, only: [:index, :search]

    with_themed_layout 'morphosource_dashboard'

    SEARCH_PATH = nil # Overwrite in controller
    PAGE_TITLE = nil # Overwrite in controller

    def index
      respond_to do |format|
        format.html do 
          @item_count = @items.total_count
        end
        format.csv  do
          prepare_items_for_csv
        end
      end

      render 'itemtable/index'
    end

    def search
      @search = true
      index
    end

    private

    def search_path
      self.class::SEARCH_PATH
    end
    helper_method :search_path

    def page_title
      self.class::PAGE_TITLE
    end
    helper_method :page_title

    def split_filter_user_keys
      if params.dig(:filter_items, :user_id).present? 
        params[:filter_items][:user_id] = params[:filter_items][:user_id].split(',')
      end
    end
  end
end