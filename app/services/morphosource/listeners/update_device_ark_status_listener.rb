# frozen_string_literal: true

module Morphosource
  module Listeners
    # Enqueue ARK status updates for changed DeviceResource works.
    class UpdateDeviceArkStatusListener
      def on_object_metadata_updated(event)
        payload = event.respond_to?(:payload) ? event.payload : {}
        object = payload[:object]
        return unless object.is_a?(DeviceResource)

        UpdateWorkArkStatusJob.perform_later(object.id.to_s)
      end
    end
  end
end
