module Hyrax
  class MsTransfersPresenter < TransfersPresenter
    def initialize(current_user, view_context, request)
      @current_user = current_user
      @view_context = view_context
      @request = request
    end

    def render_sent_transfers
      if outgoing_proxy_deposits.present?
        render 'hyrax/transfers/sent', outgoing_proxy_deposits: paginated_outgoing_proxy_deposits
      else
        t('hyrax.dashboard.no_transfers')
      end
    end

    def render_received_transfers
      if incoming_proxy_deposits.present?
        render 'hyrax/transfers/received', incoming_proxy_deposits: paginated_incoming_proxy_deposits
      else
        t('hyrax.dashboard.no_transfer_requests')
      end
    end

    private

      # pagination methods - incoming
      def paginated_incoming_proxy_deposits
        Kaminari.paginate_array(incoming_proxy_deposits, total_count: incoming_total_items).page(incoming_current_page).per(incoming_rows_from_params)
      end

      def incoming_total_items
        incoming_proxy_deposits.count
      end

      def incoming_current_page
        page = @request.params[:page].nil? ? 1 : @request.params[:page].to_i
        page > incoming_total_pages ? incoming_total_pages : page
      end

      def incoming_total_pages
        (incoming_total_items.to_f / incoming_rows_from_params.to_f).ceil
      end

      def incoming_rows_from_params
        @request.params[:rows].nil? ? Hyrax.config.teams_show_work_item_rows : @request.params[:rows].to_i
      end

      # pagination methods - outgoing
      def paginated_outgoing_proxy_deposits
        Kaminari.paginate_array(outgoing_proxy_deposits, total_count: outgoing_total_items).page(outgoing_current_page).per(outgoing_rows_from_params)
      end

      def outgoing_total_items
        outgoing_proxy_deposits.count
      end

      def outgoing_current_page
        page = @request.params[:spage].nil? ? 1 : @request.params[:spage].to_i
        page > outgoing_total_pages ? outgoing_total_pages : page
      end

      def outgoing_total_pages
        (outgoing_total_items.to_f / outgoing_rows_from_params.to_f).ceil
      end

      def outgoing_rows_from_params
        @request.params[:srows].nil? ? Hyrax.config.teams_show_work_item_rows : @request.params[:srows].to_i
      end

  end
end
