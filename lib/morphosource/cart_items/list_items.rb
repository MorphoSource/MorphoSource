module Morphosource
  module CartItems
    module ListItems

      def get_items(page)
        @items = items(page)
      end

      def items(page)
        case page
        when 'cart'
          get_restricted_items
          cart_items = @unrestricted_items + @restricted_items
        when 'my_requests'
          cart_items = my_requests(page_from_params, rows_from_params)
          @item_count = count_text(cart_items.total_count)
        when 'new'
          cart_items = newly_requested_items
          @item_count = count_text(cart_items.count)
        when 'previous'
          cart_items = previously_requested_items
          @item_count = count_text(cart_items.count)
        when 'downloads'
          cart_items = downloaded_items(page_from_params, rows_from_params)
          @item_count = count_text(cart_items.total_count)
        end
        return cart_items 
      end

      #def solr_docs_NOT_USED(page)
      #  work_ids = self.send(options(page)[:work_ids]).uniq
      #  ActiveFedora::SolrService.query(ActiveFedora::SolrQueryBuilder.construct_query_for_ids([work_ids]), rows: 999999, method: :#post).map{ |doc| SolrDocument.new(doc) }
      #end

      # downloads page
      def uniq_downloaded_work_ids
        downloaded_work_ids.uniq
      end

      # media cart
      def get_restricted_items
        @unrestricted_items = downloadable_items
        @paginated_unrestricted_items = paginated_unrestricted_items
        @restricted_items = undownloadable_items
        @paginated_restricted_items = paginated_restricted_items
        @restricted_count = count_text(@restricted_items.count)
        @item_count = count_text(@unrestricted_items.size + @restricted_items.size)
      end

      def downloadable_items
        items_in_cart.select { |i| i.downloadable? && i.has_file_uploaded? }
      end

      def undownloadable_items
        items_in_cart.select(&:restricted?)
      end

      def page_from_params
        params[:page] ||= 1
      end

      def rows_from_params
        request.params[:rows].nil? ? Hyrax.config.teams_show_work_item_rows : request.params[:rows].to_i
      end

      # pagination methods - unrestricted
      def paginated_unrestricted_items
        Kaminari.paginate_array(@unrestricted_items, total_count: total_items).page(current_page).per(rows_from_params)
      end

      def total_items
        @unrestricted_items.count
      end

      def current_page
        page = request.params[:page].nil? ? 1 : request.params[:page].to_i
        page > total_pages ? total_pages : page
      end

      # @return [Integer] total number of pages of viewable items
      def total_pages
        (total_items.to_f / rows_from_params.to_f).ceil
      end

      # pagination methods - restricted
      def paginated_restricted_items
        Kaminari.paginate_array(@restricted_items, total_count: restricted_total_items).page(restricted_current_page).per(restricted_rows_from_params)
      end

      def restricted_total_items
        @restricted_items.count
      end

      def restricted_current_page
        rpage = request.params[:rpage].nil? ? 1 : request.params[:rpage].to_i
        rpage > restricted_total_pages ? restricted_total_pages : rpage
      end

      # @return [Integer] total number of pages of viewable items
      def restricted_total_pages
        (restricted_total_items.to_f / restricted_rows_from_params.to_f).ceil
      end

      def restricted_rows_from_params
        request.params[:rows].nil? ? Hyrax.config.teams_show_work_item_rows : request.params[:rows].to_i
      end

      # media cart page
      delegate :downloadable_items_in_cart, :item_ids_in_cart, :work_ids_in_cart, to: :current_user

      # downloads page
      delegate :downloaded_items, :downloaded_work_ids, to: :current_user

      # my requests page
      delegate :my_requests, :my_requests_ids, :my_requests_work_ids, to: :current_user

      # request manager - new requests
      delegate :newly_requested_item_ids, :newly_requested_item_work_ids, to: :current_user

      # request manager - previous requests
      delegate :previously_requested_item_ids, :previously_requested_items_work_ids, to: :current_user
    end
  end
end
