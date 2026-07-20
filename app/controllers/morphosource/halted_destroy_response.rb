module Morphosource
  # Prepend (not include) this in a work controller. Two problems in the stock Hyrax destroy
  # flow, both relevant once a curation concern can refuse to be destroyed (e.g.
  # Morphosource::PhysicalObjectBehavior's has-media guard):
  #
  # 1. Hyrax::WorksControllerBehavior#destroy does `return unless actor.destroy(env)` -- a
  #    halted destroy leaves the action with no explicit response, and Rails' implicit
  #    render falls back to an empty 204 instead of a clear message.
  #
  # 2. Worse: Hyrax::Actors::CleanupFileSetsActor (part of the default actor middleware
  #    stack, run via `actor.destroy(env)`) unconditionally calls
  #    `Hyrax::SolrService.delete(curation_concern.id)` *before* the chain reaches the
  #    model and its before_destroy callbacks. So even when a before_destroy callback
  #    correctly halts the underlying Fedora delete, the object's Solr document has
  #    already been removed by the time that happens -- a "zombie" record: still in
  #    Fedora, invisible everywhere Solr-based (search, browse, media lookups). A
  #    model-level callback cannot prevent this; it fires too late in this specific path.
  #    So for any curation concern that responds to #blocking_media_message (see
  #    Morphosource::PhysicalObjectBehavior), check *before* even invoking the actor
  #    stack, and skip it entirely if media are present. That shared method forces a Solr
  #    commit first, so this check can't be beaten by media attached moments earlier that
  #    the model-level guard would otherwise catch after the Solr doc is already gone.
  #
  # Must be `prepend`ed: Ruby's `include` resolves later-included modules first, so a
  # plain `include` here would be shadowed by Hyrax::WorksControllerBehavior#destroy
  # regardless of include order.
  module HaltedDestroyResponse
    def destroy
      case curation_concern
      when ActiveFedora::Base
        title = curation_concern.to_s

        if curation_concern.respond_to?(:blocking_media_message) && (message = curation_concern.blocking_media_message)
          return respond_to do |wants|
            wants.html { redirect_to [main_app, curation_concern], alert: message }
            wants.json { render_json_response(response_type: :unprocessable_entity, options: { errors: { base: [message] } }) }
          end
        end

        env = Hyrax::Actors::Environment.new(curation_concern, current_ability, {})
        unless actor.destroy(env)
          message = curation_concern.errors.full_messages.to_sentence.presence || "Unable to delete #{title}."
          return respond_to do |wants|
            wants.html { redirect_to [main_app, curation_concern], alert: message }
            wants.json { render_json_response(response_type: :unprocessable_entity, options: { errors: curation_concern.errors }) }
          end
        end
        Hyrax.config.callback.run(:after_destroy, curation_concern.id, current_user, warn: false)
      else
        transactions['work_resource.destroy']
          .with_step_args('work_resource.delete' => { user: current_user },
                          'work_resource.delete_all_file_sets' => { user: current_user })
          .call(curation_concern).value!

        title = Array(curation_concern.title).first
      end

      after_destroy_response(title)
    end
  end
end
