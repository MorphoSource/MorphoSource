module Morphosource
  module My
    class MediaCartsController < Hyrax::MyController
      helper CartItemHelper
      include Morphosource::CartItems
      include Morphosource::CartItems::ListItems
      include Morphosource::Breadcrumbs
      with_themed_layout 'morphosource_dashboard'
      before_action :check_recaptcha, only: [:download]

      PAGE_TITLE = I18n.t("morphosource.dashboard.my.media_cart.page_title")

      def index
        get_items('cart')
        #get_restricted_items
        render 'morphosource/my/cart/index'
      end

      def download
        session[:recaptcha_verfied_in_cart] = true
        get_downloadable_items
        get_work_ids_by_items
        usage = request.params['usage'].present? ? request.params['usage'] : ''
        usage_list = request.params['usage_list'].present? ? request.params['usage_list'] : ''
        download_uuid = SecureRandom.uuid
        session[:download_keys] ||= {}
        # Prune entries older than 12 hours, then apply a hard cap as a safety valve.
        # Abandoned downloads are never actively cleaned up, so this bounds session growth
        # while keeping recent entries available for retries and range-request resumes.
        session[:download_keys].delete_if { |_, v| v[:at].to_i < 12.hours.ago.to_i }
        session[:download_keys].shift while session[:download_keys].size >= 20
        session[:download_keys][download_uuid] = { keys: access_control_ids_from_work_ids, at: Time.current.to_i }
        redirect_to main_app.media_download_path(
          token: current_user.token,
          download: download_uuid,
          usage: usage,
          usage_list: usage_list
        )
      end

      def destroy
        get_items_by_id(id_params || item_ids_in_cart)
        flash[:notice] = destroy_flash
        remove_from_cart
        redirect_back(fallback_location: my_cart_path)
      end

      def is_requests_page?
        request.referer.include? 'requests'
      end


      private

      def check_recaptcha
        unless verify_recaptcha
          if request.referer.present?
            flash[:error] = "reCAPTCHA verification has expired.  Please try again."
            redirect_to request.referer
          else
            head(:unauthorized)
          end
        end
      end

      # if a user selects items, get only those - otherwise get all downloadable items
      # an item is downloadable if it is in the cart and downloadable
      def get_downloadable_items
        if is_requests_page?
          @items = id_params ? get_items_by_id(id_params) & downloadable_all_items : downloadable_all_items
        else
          @items = id_params ? get_items_by_id(id_params) & downloadable_items : downloadable_items
        end
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
