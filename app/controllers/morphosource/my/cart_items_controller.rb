module Morphosource
  module My
    class CartItemsController < Hyrax::MyController

      include Morphosource::CartItems
      with_themed_layout 'morphosource_dashboard'      

      class_attribute :create_work_presenter_class
      self.create_work_presenter_class = Hyrax::SelectTypeListPresenter

      # Used by Add to Cart button on Work showcase page
      def create
        work = Media.find(params[:work_id])
        if work.can_add_to_cart? || current_user.can?(:download, work.id)
          unless work_already_in_cart?(work.id)
            if work_requested?(work.id)
              item = find_requested_item(work.id)
              mark_as('in_cart',item,value: true)
              flash[:notice] = 'Previously Requested Item Moved to Cart'
            else
              item = create_cart_item(work.id)
              flash[:notice] = 'Item Added to Cart'
            end
          else
            flash[:alert] = 'Item Already in Cart'
          end
        else
          flash[:alert] = 'Download Unauthorized'
        end
        redirect_back(fallback_location: my_cart_path)
      end

      # Used by Batch Add to Cart button on Work showcase page
      def batch_create
        work_ids = params[:batch_work_ids] || []
        success_count = 0
        already_count = 0
        requested_count = 0
        work_ids.each do |id|
          work = Media.find(id)
          if work.present? && (work.can_add_to_cart? || (current_user.can? :download, work))
            unless work_already_in_cart?(work.id)
              if work_requested?(work.id)
                item = find_requested_item(work.id)
                mark_as('in_cart',item,value: true)
                requested_count = requested_count + 1
              else
                item = create_cart_item(work.id)
                success_count = success_count + 1
              end
            else
              already_count = already_count + 1
            end
          end
        end
        notice = ''
        alert = ''
        if success_count > 0
          notice = success_count.to_s + ' item'.pluralize(success_count) + ' added to cart for download.  '
        end
        if already_count > 0
          alert += already_count.to_s + ' item'.pluralize(already_count) + ' already in the cart for download.  '
        end
        if requested_count > 0
          alert += requested_count.to_s + ' item'.pluralize(requested_count) + ' have been requested for download already.  '
        end
        flash[:notice] = notice if notice.present?
        flash[:alert] = alert if alert.present?
        redirect_back(fallback_location: my_cart_path)
      end

      delegate :work_ids_in_cart, to: :current_user
    end
  end
end
