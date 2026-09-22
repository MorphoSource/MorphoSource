module Morphosource
  module My
    class TransfersSentController < Morphosource::ItemtableController
      include Morphosource::TransfersControllerBehavior

      before_action :authenticate_user!

      PAGE_TITLE = I18n.t("morphosource.dashboard.my.transfers_sent.page_title")
      PAGE_DESCRIPTION = I18n.t("morphosource.dashboard.my.transfers_sent.page_description")

      def batch_cancel
        requests = pending_requests_for_batch(:destroy)
        process_batch_decisions(requests, 'cancel')
        redirect_with_batch_notice(requests, main_app.transfers_sent_path,
          success_message: I18n.t('morphosource.dashboard.my.transfers_sent.batch_cancel_notice', count: requests.size))
      end

      private

        def base_transfer_scope
          ProxyDepositRequest.where(sending_user: current_user)
        end
    end
  end
end
