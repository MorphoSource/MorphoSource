module Morphosource
  # Prepend (not include) into a work controller whose curation_concern_type is an
  # ActiveFedora::Base. Hyrax::WorksControllerBehavior#destroy does
  # `return unless actor.destroy(env)` -- a halted destroy (a before_destroy callback
  # throwing :abort, or any actor in the stack returning false) leaves the action with
  # no explicit response, so Rails' implicit render falls back to an empty 204 instead
  # of an error. Mirrors the failure handling #create/#update already have via
  # after_create_error/after_update_error.
  #
  # Must be `prepend`ed: Ruby's `include` resolves later-included modules first, so a
  # plain `include` here would be shadowed by Hyrax::WorksControllerBehavior#destroy
  # regardless of include order.
  module HaltedDestroyResponse
    def destroy
      return super unless curation_concern.is_a?(ActiveFedora::Base)

      title = curation_concern.to_s
      env = Hyrax::Actors::Environment.new(curation_concern, current_ability, {})
      return after_destroy_halted(title) unless actor.destroy(env)

      Hyrax.config.callback.run(:after_destroy, curation_concern.id, current_user, warn: false)
      after_destroy_response(title)
    end

    private

    def after_destroy_halted(title)
      message = curation_concern.errors.full_messages.to_sentence.presence || "Unable to delete #{title}."
      respond_to do |wants|
        wants.html { redirect_to [main_app, curation_concern], alert: message }
        wants.json { render_json_response(response_type: :unprocessable_entity, options: { errors: curation_concern.errors }) }
      end
    end
  end
end
