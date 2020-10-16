module Morphosource
  module My
    class MediaCartsController < Hyrax::MyController
      helper CartItemHelper
      include Morphosource::CartItems
      include Morphosource::CartItems::ListItems

      def index
        get_items('cart')
        get_restricted_items
        get_download_agreements
        render 'morphosource/my/cart/index'
      end

      def get_download_agreements
        agreements = []
        @items.each do |item|
          media = Media.find(item.work_id)
          descriptions = media.morphosource_use_agreement_type.first +
            ' (' + media.permits_commercial_use.first +
            ', ' + media.required_archival_of_published_derivatives.first +
            ', ' + media.permits_3d_use.first +
            ')'
          agreements << descriptions
        end
        @agreements_group = agreements.inject(Hash.new(0)) { |h, e| h[e] += 1 ; h }
      end


      def download
        get_downloadable_items
        get_work_ids_by_items
        redirect_to main_app.zip_path(ids: @work_ids)
      end

      def destroy
        get_items_by_id(id_params || item_ids_in_cart)
        flash[:notice] = destroy_flash
        remove_from_cart
        redirect_back(fallback_location: my_cart_path)
      end

      private

      # if a user selects items, get only those - otherwise get all downloadable items
      # an item is downloadable if it is in the cart and downloadable
      def get_downloadable_items
        @items = id_params ? get_items_by_id(id_params) & downloadable_items : downloadable_items
      end

      def destroy_flash
        "#{item_count_text} Removed from Cart"
      end

      def remove_from_cart
        @items.each do |item|
          if item.date_downloaded? || item.date_requested?
            item.in_cart = false
            item.save
          else
            item.destroy
          end
        end
      end
    end
  end
end
