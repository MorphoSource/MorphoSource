# frozen_string_literal: true

# Migrates a single AF ::FileSet record to a Valkyrie Hyrax::FileSet record.
#
# Enqueue manually to migrate individual or all AF FileSets:
#
#   MigrateFileSetToValkyrieJob.perform_later(id: 'abc123')
#
#   ::FileSet.find_each { |fs| MigrateFileSetToValkyrieJob.perform_later(id: fs.id) }
#
# Migration steps:
#   1. Load resource via Wings; guard if already migrated (wings? == false).
#   2. MigrateResourceService saves metadata to Postgres via change_set.update_file_set.
#   3. FreyjaWithWings::Persister#convert_and_migrate_resource updates the parent AF work's
#.     valkyrie_member_ids to reference the Postgres FileSet.
#   3. FreyjaWithWings::Persister#convert_and_migrate_resource auto-enqueues
#      MigrateFilesToValkyrieJob for any fedora:// file binaries
#      or MigrateExternalFilesToValkyrieJob for any external files.

class MigrateFileSetToValkyrieJob < ApplicationJob
  queue_as Hyrax.config.update_medium_queue_name

  # @param id [String] the AF FileSet ID
  def perform(id:)
    resource = Hyrax.query_service.find_by(id: id)
    return unless resource.respond_to?(:wings?) && resource.wings?

    result = MigrateResourceService.new(resource: resource).call
    Rails.logger.error("MigrateFileSetToValkyrieJob: failed to migrate #{id}: #{result.failure}") unless result.success?
  rescue Valkyrie::Persistence::ObjectNotFoundError
    Rails.logger.warn("MigrateFileSetToValkyrieJob: FileSet #{id} not found, skipping")
  end
end
