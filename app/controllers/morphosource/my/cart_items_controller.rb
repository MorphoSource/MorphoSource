module Morphosource
  module My
    class CartItemsController < Hyrax::MyController

      include Morphosource::CartItems

      class_attribute :create_work_presenter_class
      self.create_work_presenter_class = Hyrax::SelectTypeListPresenter

      # Used by Add to Cart button on Work showcase page
      def create
        work = Media.find(params[:work_id])
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
        redirect_back(fallback_location: my_cart_path)
      end

      # Used by Batch Add to Cart button on Work showcase page
      def batch_create
        work_ids = params[:batch_work_ids]
        success_count = 0
        already_count = 0
        requested_count = 0
        work_ids.each do |id|
          work = Media.find(id)
          if work.present?
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

      # Used when downloading from the showcase page
      def download
        work_id = params[:work_id].first
        if downloadable_item_for_work?(work_id)
          item = find_downloadable_item(work_id)
          if item.date_downloaded
            create_downloaded_item(work_id)
          else
            mark_as('downloaded',item)
          end
        else
          create_downloaded_item(work_id)
        end
        redirect_to main_app.zip_hyrax_media_index_path(ids: [work_id])
      end
    end
  end
end
