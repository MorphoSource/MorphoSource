# frozen_string_literal: true
# rubocop:disable Metrics/BlockLength

require 'freyja_with_wings/metadata_adapter'
require 'freyja_with_wings/persister'

# Freyja setup adapted from Hyrax dassie and thereby from hyku
if Hyrax.config.valkyrie_transition?
  Rails.application.config.after_initialize do
    [ # List AF work models
      Taxonomy,
      Device
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

    # Register custom query strategies for find_first/last_of_model and find_all_by_metadata_properties
    Freyja::CustomQueryContainer.known_custom_queries_and_their_strategies =
      Freyja::CustomQueryContainer.known_custom_queries_and_their_strategies.merge(
        find_first_of_model: :find_single_or_nil,
        find_last_of_model: :find_single_or_nil,
        find_all_by_metadata_properties: :find_multiple
      )

    Valkyrie::StorageAdapter.register(
      Valkyrie::Storage::VersionedDisk.new(base_path: Rails.root.join("storage", "files"),
        file_mover: FileUtils.method(:cp)),
      :disk
    )
    Valkyrie.config.storage_adapter = :disk

    Hyrax.config.index_adapter = :solr_index
  end

  Rails.application.config.to_prepare do
    AdminSetResource.class_eval do
      attribute :internal_resource, Valkyrie::Types::Any.default("AdminSet"), internal: true
    end

    Valkyrie.config.resource_class_resolver = lambda do |resource_klass_name|
      # TODO: Can we use some kind of lookup.

      # Valkyrie-only resources (no Wings/AF counterpart) must be resolved
      # directly before the suffix-stripping logic below, otherwise
      # "ImagingEventResource" would be stripped to "ImagingEvent" and resolved
      # to the AF ImagingEvent class instead of ImagingEventResource.
      # Do NOT add these to the Taxonomy list below — that list also applies to
      # Wings-loaded AF objects (e.g. "Wings(ImagingEvent)"), which should
      # remain as AF objects and not be translated to their Resource counterpart.
      valkyrie_only_resources = %w[ImagingEventResource]
      return resource_klass_name.constantize if valkyrie_only_resources.include?(resource_klass_name)

      klass_name = resource_klass_name.gsub(/^Wings\((.+)\)$/, '\1')
      klass_name = klass_name.gsub(/Resource$/, '')
      if %w[
        Taxonomy
        Device
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
