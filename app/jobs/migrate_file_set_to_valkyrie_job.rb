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
#   3. FreyjaWithWings::Persister#convert_and_migrate_resource auto-enqueues
#      MigrateFilesToValkyrieJob for any fedora:// file binaries (when VALKYRIE_TRANSITION=true).
#   4. Update the parent AF work's valkyrie_member_ids to reference the Postgres FileSet.
class MigrateFileSetToValkyrieJob < ApplicationJob
  queue_as Hyrax.config.update_medium_queue_name

  # @param id [String] the AF FileSet ID
  def perform(id:)
    resource = Hyrax.query_service.find_by(id: id)
    return unless resource.respond_to?(:wings?) && resource.wings?

    result = MigrateResourceService.new(resource: resource).call
    unless result.success?
      Rails.logger.error("MigrateFileSetToValkyrieJob: failed to migrate #{id}: #{result.failure}")
      return
    end

    update_parent_work_membership(id)
  rescue Valkyrie::Persistence::ObjectNotFoundError
    Rails.logger.warn("MigrateFileSetToValkyrieJob: FileSet #{id} not found, skipping")
  end

  private

  # Adds the migrated FileSet ID to the parent AF work's valkyrie_member_ids so
  # the work can find the now-Postgres FileSet via the fast Postgres path.
  def update_parent_work_membership(id)
    af_file_set = ::FileSet.find(id)
    parent = af_file_set.parent
    return unless parent.present? && parent.respond_to?(:valkyrie_member_ids)

    parent.reload unless parent.new_record?
    parent.ordered_members.delete(af_file_set)
    parent.members.delete(af_file_set)
    parent.valkyrie_member_ids = (parent.valkyrie_member_ids.to_a + [id]).uniq
    parent.save!
  rescue StandardError => e
    Rails.logger.error("MigrateFileSetToValkyrieJob: failed to update parent for #{id}: #{e.message}")
  end
end
