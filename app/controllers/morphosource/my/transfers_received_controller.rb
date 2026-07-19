module Morphosource
  module My
    class TransfersReceivedController < Morphosource::ItemtableController
      include Morphosource::TransfersControllerBehavior

      before_action :authenticate_user!

      PAGE_TITLE = I18n.t("morphosource.dashboard.my.transfers_received.page_title")
      PAGE_DESCRIPTION = I18n.t("morphosource.dashboard.my.transfers_received.page_description")

      def batch_accept
        requests = pending_requests_for_batch(:accept)
        process_batch_decisions(requests, 'accept', reset: params[:reset].present?, sticky: params[:sticky].present?)
        redirect_with_batch_notice(requests, main_app.transfers_received_path,
          success_message: "#{requests.size} transfer(s) accepted. Ownership changes are being applied in the background and should complete shortly.")
      end

      def batch_reject
        requests = pending_requests_for_batch(:reject)
        process_batch_decisions(requests, 'reject')
        redirect_with_batch_notice(requests, main_app.transfers_received_path,
          success_message: "#{requests.size} transfer(s) rejected.")
      end

      private

        def base_transfer_scope
          ProxyDepositRequest.where(receiving_user_id: current_user.collections_managed_ids + [current_user.id])
        end
    end
  end
end
