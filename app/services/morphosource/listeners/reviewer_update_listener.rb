# frozen_string_literal: true

module Morphosource
  module Listeners
    # Refreshes the reviewer lists cached on CartItem rows. Handlers only enqueue;
    # Hyrax.publisher dispatches synchronously. Both are inert until their jobs exist.
    class ReviewerUpdateListener
      # @param event [Dry::Events::Event] payload +{ media_id: String }+
      def on_media_reviewers_updated(event); end

      # @param event [Dry::Events::Event] payload +{ organization_id: String }+
      def on_organization_reviewers_updated(event); end
    end
  end
end
