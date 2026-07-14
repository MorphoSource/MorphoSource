module Morphosource
  module My
    class TransfersSentController < Morphosource::ItemtableController
      include Morphosource::TransfersItemtableBehavior

      before_action :authenticate_user!

      PAGE_TITLE = I18n.t("morphosource.dashboard.my.transfers_sent.page_title")
      PAGE_DESCRIPTION = I18n.t("morphosource.dashboard.my.transfers_sent.page_description")

      def batch_cancel
        requests = pending_requests_for_batch(:destroy)
        enqueue_transfer_decisions(requests, 'cancel')
        redirect_to main_app.transfers_sent_path, notice: "#{requests.size} transfer(s) are being processed."
      end

      private

        def base_transfer_scope
          ProxyDepositRequest.where(sending_user: current_user)
        end
    end
  end
end
