# frozen_string_literal: true
# rubocop:disable Metrics/BlockLength

require 'freyja_with_wings/metadata_adapter'
require 'freyja_with_wings/persister'

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
      FreyjaWithWings::MetadataAdapter.new,
      :freyja
    )
    Valkyrie.config.metadata_adapter = :freyja
    Hyrax.config.query_index_from_valkyrie = true

    Valkyrie::StorageAdapter.register(
      Valkyrie::Storage::Hoard.new(services: [
        Valkyrie::Storage::VersionedDisk.new(
          base_path: Rails.root.join("storage", "files"),
          file_mover: FileUtils.method(:cp)
        ),
        Valkyrie::Storage::ExternalUrl.new
      ]),
      :hoard
    )
    Valkyrie.config.storage_adapter = :hoard

    Hyrax.config.index_adapter = :solr_index
  end

  Rails.application.config.to_prepare do
    AdminSetResource.class_eval do
      attribute :internal_resource, Valkyrie::Types::Any.default("AdminSet"), internal: true
    end

    Valkyrie.config.resource_class_resolver = lambda do |resource_klass_name|
      # TODO: Can we use some kind of lookup.
      klass_name = resource_klass_name.gsub(/^Wings\((.+)\)$/, '\1')
      klass_name = klass_name.gsub(/Resource$/, '')
      if %w[
        Taxonomy
      ].include?(klass_name)
        "#{klass_name}Resource".constantize
      elsif 'AdminSet' == klass_name
        AdminSetResource
        # Without this mapping, we'll see cases of Postgres Valkyrie adapter attempting to write to
        # Fedora.  Yeah!
      elsif 'Hydra::AccessControl' == klass_name
        Hyrax::AccessControl
      elsif 'FileSet' == klass_name
        Hyrax::FileSet
      elsif 'Hydra::AccessControls::Embargo' == klass_name
        Hyrax::Embargo
      elsif 'Hydra::AccessControls::Lease' == klass_name
        Hyrax::Lease
      elsif 'Hydra::PCDM::File' == klass_name
        Hyrax::FileMetadata
      else
        klass_name.constantize
      end
    end
  end
end