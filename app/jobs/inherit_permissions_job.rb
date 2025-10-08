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
        return unless Morphosource::Works::Base.exists?(work)
        work = Morphosource::Works::Base.find(work)
      end

      fileset_ids = work.file_sets&.map(&:id)
      Rails.logger.info "[InheritPermissionsJob] Copying permissions from work #{work.id} to filesets #{fileset_ids.join(', ')}"

      work.file_sets.each do |file|
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
    rescue StandardError => e
      if (retries += 1) <= 3
        sleep 10 # Try and wait out whatever other permissions changes are happening
        retry
      else
        raise e, "Maximum number of retries reached. Last exception message: #{e.message}"
      end
    end
  end
end