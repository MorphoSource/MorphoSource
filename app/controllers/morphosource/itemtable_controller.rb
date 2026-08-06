# Display list of all downloads from all users for admin
module Morphosource
  class ItemtableController < ApplicationController
    include Morphosource::ItemtableControllerBehavior
    include Morphosource::ItemtableHelper
    include Morphosource::Breadcrumbs

    before_action :get_items, only: [:index]
    before_action :split_filter_user_keys, only: [:index]
    before_action :filter_items, only: [:index]
    before_action :paginate_items, only: [:index]
    before_action :build_breadcrumbs, only: [:index]

    with_themed_layout 'morphosource_dashboard'

    PAGE_TITLE = nil # Overwrite in controller
    PAGE_DESCRIPTION = nil # Overwrite in controller if desired

    def index
      @search = true if search_form_present?

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

    def page_description
      self.class::PAGE_DESCRIPTION
    end
    helper_method :page_description

    # Whether search-filter panel above the table renders as bordered card with a smaller
    # title, matching the .panel-borders convention used elsewhere on the site (e.g.
    # my/collections#index). Override to false in a controller or concern to opt out.
    def bordered_search_panel?
      true
    end
    helper_method :bordered_search_panel?

    def search_form_present?
      params[:search].present? || params[:commit] == 'Search' || params[:filter_items].present?
    end
  end
end