module Morphosource
  module My
    class TransfersReceivedController < Morphosource::ItemtableController
      include Morphosource::TransfersItemtableBehavior

      before_action :authenticate_user!

      PAGE_TITLE = I18n.t("morphosource.dashboard.my.transfers_received.page_title")
      PAGE_DESCRIPTION = I18n.t("morphosource.dashboard.my.transfers_received.page_description")

      def batch_accept
        requests = pending_requests_for_batch(:accept)
        enqueue_transfer_decisions(requests, 'accept', reset: params[:reset].present?, sticky: params[:sticky].present?)
        redirect_to main_app.transfers_received_path, notice: "#{requests.size} transfer(s) are being processed."
      end

      def batch_reject
        requests = pending_requests_for_batch(:reject)
        enqueue_transfer_decisions(requests, 'reject')
        redirect_to main_app.transfers_received_path, notice: "#{requests.size} transfer(s) are being processed."
      end

      private

        def base_transfer_scope
          ProxyDepositRequest.where(receiving_user_id: current_user.collections_managed_ids + [current_user.id])
        end
    end
  end
end
