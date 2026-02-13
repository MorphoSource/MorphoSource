# frozen_string_literal: true

module Morphosource
  module Listeners
    class DeleteDeviceReservedArkListener
      def on_object_deleted(event)
        payload = event.respond_to?(:payload) ? event.payload : {}
        object = payload[:object]
        return unless object.is_a?(DeviceResource)

        ark = payload[:deleted_ark].presence || Array(object.ark).first
        return if ark.blank?

        DeleteReservedArkJob.perform_later(ark)
      end
    end
  end
end
