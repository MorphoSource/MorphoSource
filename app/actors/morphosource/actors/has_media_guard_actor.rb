module Morphosource
  module Actors
    # Must run before Hyrax::Actors::CleanupFileSetsActor, which deletes the Solr doc
    # unconditionally -- too late for a model-level before_destroy guard to prevent a
    # "zombie" record (gone from Solr, still in Fedora).
    class HasMediaGuardActor < Hyrax::Actors::AbstractActor
      def destroy(env)
        curation_concern = env.curation_concern
        if curation_concern.respond_to?(:blocking_media_message) && (message = curation_concern.blocking_media_message)
          curation_concern.errors.add(:base, message)
          return false
        end

        next_actor.destroy(env)
      end
    end
  end
end
