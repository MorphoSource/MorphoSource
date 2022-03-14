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

      def field_transform(k)
				case k
				when 'work_id'
					'media_id'
				when 'user_id'
					'download_user'
        when 'action_by'
          'decision_user'
        when 'reviewers'
          'current_reviewers'
				else
					k
				end
			end
		
			def value_transform(k, v)
				case k
				when 'user_id', 'action_by', 'reviewers'
					User.find_by_user_key(v).present? ? User.find_by_user_key(v).name_and_email : v
				else
					v
				end
			end
    end
  end
end