# frozen_string_literal: true

module Morphosource
  module Listeners
    class DeleteReservedArkListener
      def on_object_deleted(event)
        payload = event.respond_to?(:payload) ? event.payload : {}
        ark = payload[:deleted_ark].presence
        return if ark.blank?

        DeleteReservedArkJob.perform_later(ark)
      end
    end
  end
end
