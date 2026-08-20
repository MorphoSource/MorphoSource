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
          success_message: I18n.t('morphosource.dashboard.my.transfers_received.batch_accept_notice', count: requests.size))
      end

      def batch_reject
        requests = pending_requests_for_batch(:reject)
        process_batch_decisions(requests, 'reject')
        redirect_with_batch_notice(requests, main_app.transfers_received_path,
          success_message: I18n.t('morphosource.dashboard.my.transfers_received.batch_reject_notice', count: requests.size))
      end

      private

        def base_transfer_scope
          return ProxyDepositRequest.none unless current_user
          ProxyDepositRequest.where(receiving_user_id: current_user.collections_managed_ids + [current_user.id])
        end
    end
  end
end
