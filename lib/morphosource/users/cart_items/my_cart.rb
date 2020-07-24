module Morphosource
  module Users
    module CartItems
      module MyCart

        def items_in_cart
          cart_items.select(&:in_cart?)
        end

        def item_ids_in_cart
          items_in_cart.map(&:id)
        end

        def work_ids_in_cart
          items_in_cart.map(&:work_id)
        end

        # restricted items user has added to cart
        def restricted_items_in_cart
          items_in_cart.select(&:restricted?)
        end

        def restricted_items_in_cart_ids
          restricted_items_in_cart.map(&:id)
        end

        def downloadable_items
          cart_items.select(&:downloadable?)
        end

        def downloadable_ids
          downloadable_items.map(&:id)
        end

        def downloadable_item_work_ids
          downloadable_items.map(&:work_id)
        end

        def downloadable_items_in_cart
          downloadable_items.select(&:in_cart?)
        end

        def downloadable_ids_in_cart
          downloadable_items_in_cart.map(&:id)
        end
      end
    end
  end
end
