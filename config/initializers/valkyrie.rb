# frozen_string_literal: true
# rubocop:disable Metrics/BlockLength

# Freyja setup adapted from Hyrax dassie and thereby from hyku
if Hyrax.config.valkyrie_transition?
  Rails.application.config.after_initialize do
    [ # List AF work models
      Taxonomy
    ].each do |klass|
      Wings::ModelRegistry.register("#{klass}Resource".constantize, klass)
      # we register itself so we can pre-translate the class in Freyja instead of having to translate in each query_service
      Wings::ModelRegistry.register(klass, klass)
    end
    Wings::ModelRegistry.register(Collection, Collection)
    Wings::ModelRegistry.register(CollectionResource, Collection)
    Wings::ModelRegistry.register(AdminSet, AdminSet)
    Wings::ModelRegistry.register(AdminSetResource, AdminSet)
    Wings::ModelRegistry.register(FileSet, FileSet)
    Wings::ModelRegistry.register(Hyrax::FileSet, FileSet)
    Wings::ModelRegistry.register(Hydra::PCDM::File, Hydra::PCDM::File)
    Wings::ModelRegistry.register(Hyrax::FileMetadata, Hydra::PCDM::File)

    Valkyrie::MetadataAdapter.register(
      Freyja::MetadataAdapter.new,
      :freyja
    )
    Valkyrie.config.metadata_adapter = :freyja
    Hyrax.config.query_index_from_valkyrie = true
    Hyrax.config.index_adapter = :solr_index
  end
end