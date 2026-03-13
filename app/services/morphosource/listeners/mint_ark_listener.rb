# frozen_string_literal: true

module Morphosource
  module Listeners
    # Enqueue ARK minting for newly deposited resources that support minting.
    class MintArkListener
      def on_object_deposited(event)
        payload = event.respond_to?(:payload) ? event.payload : {}
        object = payload[:object]
        return unless object.respond_to?(:id) && object.respond_to?(:mint_ark)

        MintWorkArkJob.perform_later(object.id.to_s)
      end
    end
  end
end
