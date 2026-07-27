module Morphosource
  # Hyrax::WorksControllerBehavior#destroy does `return unless actor.destroy(env)` --
  # a halted destroy leaves no flash/error response, just a silent empty 204. Mirrors
  # the failure handling #create/#update already have. Must be `prepend`ed, not
  # `include`d, or it's shadowed by Hyrax::WorksControllerBehavior#destroy.
  module HaltedDestroyResponse
    def destroy
      # Non-AF (Valkyrie) concerns use super's transaction branch, which already raises on failure.
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
