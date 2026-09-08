# frozen_string_literal: true

module Morphosource
  module Listeners
    # Refreshes the reviewer lists cached on CartItem rows. Handlers only enqueue;
    # Hyrax.publisher dispatches synchronously. The organization handler is activated with its lifecycle job.
    class ReviewerUpdateListener
      # @param event [Dry::Events::Event] payload +{ media_id: String }+
      def on_media_reviewers_updated(event)
        UpdateCartItemReviewersJob.perform_later(event[:media_id])
      end

      # @param event [Dry::Events::Event] payload +{ organization_id: String }+
      def on_organization_reviewers_updated(event); end
    end
  end
end
