# Display list of all ownership transfer requests, both received and sent, site-wide, for admin.
module Morphosource
  module Admin
    class TransfersController < Morphosource::ItemtableController
      include Morphosource::TransfersControllerBehavior

      before_action :require_permissions

      PAGE_TITLE = I18n.t("morphosource.admin.transfers.page_title")
      PAGE_DESCRIPTION = I18n.t("morphosource.admin.transfers.page_description")

      def batch_accept
        requests = pending_requests_for_batch(:accept)
        process_batch_decisions(requests, 'accept', reset: params[:reset].present?, sticky: params[:sticky].present?)
        redirect_with_batch_notice(requests, main_app.admin_transfers_path,
          success_message: I18n.t('morphosource.admin.transfers.batch_accept_notice', count: requests.size))
      end

      def batch_reject
        requests = pending_requests_for_batch(:reject)
        process_batch_decisions(requests, 'reject')
        redirect_with_batch_notice(requests, main_app.admin_transfers_path,
          success_message: I18n.t('morphosource.admin.transfers.batch_reject_notice', count: requests.size))
      end

      def batch_cancel
        requests = pending_requests_for_batch(:destroy)
        process_batch_decisions(requests, 'cancel')
        redirect_with_batch_notice(requests, main_app.admin_transfers_path,
          success_message: I18n.t('morphosource.admin.transfers.batch_cancel_notice', count: requests.size))
      end

      private

        def require_permissions
          authorize! :read, :admin_dashboard
        end

        def base_transfer_scope
          ProxyDepositRequest.all
        end
    end
  end
end
