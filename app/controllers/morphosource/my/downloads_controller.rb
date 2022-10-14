module Morphosource
  module My
    class DownloadsController < Hyrax::MyController
      include Morphosource::CartItems
      include Morphosource::CartItems::ListItems
      include Morphosource::DatatableControllerBehavior
      with_themed_layout 'morphosource_dashboard'

      before_action :get_items, only: :index
      before_action :paginate_and_sort_items, only: :index

      def index; end

      # Used when batch-copying previously downloaded items to cart
      def batch_create
        get_items_by_id
        get_duplicate_requests
        create_new_items(@items,nil)
        move_active_requests_to_cart
        flash[:notice] = duplicates_flash
        redirect_to main_app.my_cart_path
      end

      private

      def get_items
        @items = current_user.present? ? cart_items.where("date_downloaded IS NOT NULL").order('date_downloaded DESC') : []
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
          titles << Media.find(id).title[0]
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
