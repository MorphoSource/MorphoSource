module Morphosource
  module My
    class DownloadsController < Hyrax::MyController
      include Morphosource::CartItems
      include Morphosource::CartItems::ListItems
      include Morphosource::ItemtableControllerBehavior
      include Morphosource::ItemtableHelper
      include Morphosource::Breadcrumbs
      with_themed_layout 'morphosource_dashboard'

      before_action :get_items, only: :index
      before_action :paginate_items, only: [:index]

      PAGE_TITLE = I18n.t("morphosource.dashboard.my.downloads.page_title")

      def index
        @item_count = count_text(@items.total_count)
      end

      # Used when batch-copying previously downloaded items to cart
      def batch_create
        get_items_by_id
        get_duplicate_requests
        create_new_items(@items,nil)
        move_active_requests_to_cart
        flash[:notice] = duplicates_flash
        redirect_to main_app.my_cart_path
      end

      def allowed_sort_parameters
        ['date_downloaded asc',
         'date_downloaded desc']
      end

      private

      def get_items
        @items = current_user.present? ? current_user.cart_items.where("date_downloaded IS NOT NULL").order(sort_param) : []
      end

      def valid_sort_attributes
        ['date_downloaded']
      end

      def default_sort_param
        'date_downloaded DESC'
      end

      # If user batch selects multiple items for the same work
      def get_duplicate_requests
        @ids = get_work_ids_by_items.dup
        duplicate_work_ids
        @duplicate_requests = titles_by_id
      end

      def duplicate_work_ids
        @ids.uniq.each do |id|
          @ids.slice!(@ids.index(id)) if @ids.include?(id)
        end
      end

      def titles_by_id
        @ids.each_with_object([]) do |id,titles|
          titles << SolrDocument.find(id).title.first
        end
      end

      def duplicates_flash
        "#{count_text(@count)} Added to Cart#{duplicates_text(@duplicate_requests+@duplicates_in_cart)}#{active_requests_text}"
      end

      def duplicates_text(duplicates)
        if duplicates.count > 0
          "; #{count_text(duplicates.count)}: #{duplicates.join(', ')} Already in Your Cart"
        else
          ''
        end
      end

      def active_requests_text
        if @active_requests_moved.count > 0
          "; #{count_text(@active_requests_moved.count)} Already Requested and Moved to Your Cart."
        else
          '.'
        end
      end

      def move_active_requests_to_cart
        @items.each do |item|
          if item.active_request? && item.in_cart == false
            mark_as('in_cart',item,value: true)
          end
        end
      end

    end
  end
end
