# Display list of all ownership transfer requests, both received and sent, site-wide, for admin.
module Morphosource
  module Admin
    class TransfersController < Morphosource::ItemtableController
      include Morphosource::TransfersItemtableBehavior

      before_action :require_permissions

      PAGE_TITLE = I18n.t("morphosource.admin.transfers.page_title")
      PAGE_DESCRIPTION = I18n.t("morphosource.admin.transfers.page_description")

      def batch_accept
        requests = pending_requests_for_batch(:accept)
        enqueue_transfer_decisions(requests, 'accept', reset: params[:reset].present?, sticky: params[:sticky].present?)
        redirect_to main_app.admin_transfers_path, notice: "#{requests.size} transfer(s) are being processed."
      end

      def batch_reject
        requests = pending_requests_for_batch(:reject)
        enqueue_transfer_decisions(requests, 'reject')
        redirect_to main_app.admin_transfers_path, notice: "#{requests.size} transfer(s) are being processed."
      end

      def batch_cancel
        requests = pending_requests_for_batch(:destroy)
        requests.each do |r|
          decision = r.organization_transfer? ? 'force_cancel' : 'cancel'
          TransferDecisionJob.perform_later(r.id, decision, acting_user_id: current_user.id)
        end
        redirect_to main_app.admin_transfers_path, notice: "#{requests.size} transfer(s) are being processed."
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
