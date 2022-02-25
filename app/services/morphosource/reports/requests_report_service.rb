module Morphosource
  module Reports
    class RequestsReportService < CartItemsReportService
      self.where_chain += [:where_requested]

      def where_requested(model_or_result)
        model_or_result.where.not(date_requested: nil)
      end

      def attributes
        [:work_id, :user_id, :use, :date_requested, :date_approved, :date_denied, :date_cleared, :date_canceled, :date_expired, :date_downloaded, :action_by, :reviewers]
      end
    end
  end
end