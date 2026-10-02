# frozen_string_literal: true

module Morphosource
  module Listeners
    class ReviewerUpdateListener
      # @param event [Dry::Events::Event] payload +{ media_id: String }+
      def on_media_reviewers_updated(event)
        UpdateCartItemReviewersJob.perform_later(event[:media_id])
      end

      # @param event [Dry::Events::Event] payload +{ organization_id: String }+
      def on_organization_reviewers_updated(event)
        UpdateOrgMediaReviewersJob.perform_later(event[:organization_id])
      end
    end
  end
end
