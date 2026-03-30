# frozen_string_literal: true

module Morphosource
  module Listeners
    # Enqueue ARK status updates for changed work resources.
    class UpdateArkStatusListener
      def on_object_metadata_updated(event)
        payload = event.respond_to?(:payload) ? event.payload : {}
        object = payload[:object]
        return if !object.is_a?(Hyrax::Work) # only for work resources...
        return if !object.respond_to?(:ark) || object.ark.blank? # ...that has ARKs

        UpdateWorkArkStatusJob.perform_later(object.id.to_s)
      end
    end
  end
end
