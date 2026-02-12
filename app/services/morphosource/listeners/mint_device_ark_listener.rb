# frozen_string_literal: true

module Morphosource
  module Listeners
    # Enqueue ARK minting for newly deposited DeviceResource works.
    class MintDeviceArkListener
      def on_object_deposited(event)
        payload = event.respond_to?(:payload) ? event.payload : {}
        object = payload[:object]
        return unless object.is_a?(DeviceResource)

        MintWorkArkJob.perform_later(object.id.to_s)
      end
    end
  end
end
