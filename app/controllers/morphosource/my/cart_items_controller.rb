module Morphosource
  module My
    class CartItemsController < Hyrax::MyController

      include Morphosource::My::CartItemsBehavior

      class_attribute :create_work_presenter_class
      self.create_work_presenter_class = Hyrax::SelectTypeListPresenter

      # Used by Add to Cart button on Work showcase page
      def create
        work = Media.find(params[:work_id])
        unless work_already_in_cart?(work.id)
          if work_requested?(work.id)
            item = find_requested_item(work.id)
            mark_as('in_cart',item,value: true)
          else
            item = create_cart_item(work.id)
            if item.restricted? && user_is_approver?(item)
              unrestrict(item)
            end
          end
          flash[:notice] = 'Item Added to Cart'
        else
          flash[:alert] = 'Item Already in Cart or Requested'
        end
        redirect_back(fallback_location: my_cart_path)
      end

      # used when downloading from the showcase page
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
