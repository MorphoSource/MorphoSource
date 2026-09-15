# A job to apply work permissions to all contained files set
# Copied from Hyrax, which accepts a work as parameter input
# Models as Resque params can error when work becomes out of sync while in queue
# This version supports passing work or work ID string as parameter input
#
class InheritPermissionsJob < Hyrax::ApplicationJob
  # Perform the copy from the work to the contained filesets
  #
  # @param work [String, ActiveFedora::Base] work ID or work containing access level and filesets
  def perform(work)
    begin
      # Retry 3 times, sometimes this hits Ldp::Gone due to race conditions(?) deleting permissions
      retries ||= 0

      if work.is_a? String
        if ActiveFedora::Base.exists?(work)
          work = ActiveFedora::Base.find(work)
        else
          Rails.logger.info "[InheritPermissionsJob] Work #{work} does not exist, skipping.."
          return
        end
      end

      work.file_sets.each do |file|
        Rails.logger.info "[InheritPermissionsJob] Copying permissions from work #{work.id} to fileset #{file.id}"

        if file.is_a?(ActiveFedora::Base)
          copy_af_permissions(work: work, file: file)
        else
          copy_valkyrie_permissions(work: work, file: file)
        end
      end
    rescue StandardError => e
      if (retries += 1) <= 3
        sleep 10 # Try and wait out whatever other permissions changes are happening
        retry
      else
        raise e, "Maximum number of retries reached. Last exception message: #{e.message}"
      end
    end
  end

  private

  # Copies permissions to a legacy ActiveFedora FileSet.
  def copy_af_permissions(work:, file:)
    file.reload
    attribute_map = work.permissions.map(&:to_hash)

    # copy and removed access to the new access with the delete flag
    file.permissions.map(&:to_hash).each do |perm|
      unless attribute_map.include?(perm)
        perm[:_destroy] = true
        attribute_map << perm
      end
    end

    # apply the new and deleted attributes
    file.permissions_attributes = attribute_map
    file.save!
  end

  # Copies permissions to a Valkyrie-native FileSet. These have no AF-style
  # #permissions_attributes= / #reload -- access is managed via Hyrax::PermissionManager /
  # Hyrax::AccessControlList instead. `work` stays ActiveFedora even when its FileSets are
  # Valkyrie, so permissions are read from `work` via its normal AF accessors and written to
  # `file` via its PermissionManager, rather than casting `work` through AccessControlList
  # (which would silently yield an empty permission set for an AF resource).
  def copy_valkyrie_permissions(work:, file:)
    permission_manager = file.permission_manager
    permission_manager.edit_users      = work.edit_users
    permission_manager.edit_groups     = work.edit_groups
    permission_manager.read_users      = work.read_users
    permission_manager.read_groups     = work.read_groups
    permission_manager.discover_users  = work.discover_users
    permission_manager.discover_groups = work.discover_groups
    permission_manager.download_users  = work.download_users
    permission_manager.download_groups = work.download_groups
    permission_manager.acl.save
  end
end