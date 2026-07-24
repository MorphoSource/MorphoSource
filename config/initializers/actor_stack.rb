# Blocks a destroy at the actor-stack level (see HasMediaGuardActor) before
# Hyrax::Actors::CleanupFileSetsActor can delete the Solr doc.
Rails.application.config.to_prepare do
  Hyrax::CurationConcern.actor_factory.insert_before(
    Hyrax::Actors::CleanupFileSetsActor, Morphosource::Actors::HasMediaGuardActor
  )
end
