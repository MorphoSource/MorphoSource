module Morphosource
  module Reports
    class DownloadsReportService < CartItemsReportService
      self.where_chain += [:where_downloaded]

      def where_downloaded(model_or_result)
        model_or_result.where.not(date_downloaded: nil)
      end

      def attributes
				[:work_id, :date_downloaded, :download_usage, :download_usage_list, :user_id]
			end
    end
  end
end