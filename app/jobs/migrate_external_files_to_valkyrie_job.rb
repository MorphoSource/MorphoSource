# frozen_string_literal: true

# Registers an external HTTP/HTTPS file for a remote-backed Hyrax::FileSet
# that has been migrated from ActiveFedora to Valkyrie.
#
# MigrateFilesToValkyrieJob handles FileSets whose original file is stored in
# Fedora (fedora:// file_identifiers). This job handles the complementary case:
# FileSets whose file is an external URL recorded in file_set.import_url.
# Rather than downloading from Fedora, it creates a
# Valkyrie::StorageAdapter::ExternalFile whose ID is the import_url, exactly as
# ValkyrieRemoteIngestJob does for new remote-backed uploads.
#
# Triggered by FreyjaWithWings::Persister#convert_and_migrate_resource for newly
# Postgres-backed FileSet resources that have import_url present, in preference to
# MigrateFilesToValkyrieJob.
class MigrateExternalFilesToValkyrieJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  # @param resource [Hyrax::FileSet] the migrated Valkyrie FileSet
  def perform(resource)
    return if resource.import_url.blank?
    return if already_registered?(resource)

    uri  = URI.parse(Addressable::URI.escape(resource.import_url))
    user = User.find_by_user_key(resource.depositor)

    Morphosource::ValkyrieUpload.file(
      io:               nil,
      filename:          uri,
      file_set:          resource,
      use:              Hyrax::FileMetadata::Use::ORIGINAL_FILE,
      user:             user,
      skip_derivatives: true
    )
  rescue StandardError => e
    Rails.logger.error("MigrateExternalFilesToValkyrieJob: #{e.class} for FileSet #{resource.id}: #{e.message}")
  end

  private

  # Returns true if an ExternalFile is already registered as the original file
  # for this FileSet, preventing double-registration on reruns.
  def already_registered?(resource)
    fm = Hyrax.custom_queries.find_original_file(file_set: resource)
    Valkyrie::Storage::ExternalUrl.new.handles?(id: fm.file_identifier)
  rescue Valkyrie::Persistence::ObjectNotFoundError
    false
  end
end
