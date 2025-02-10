module Morphosource
  #
  # MigrateAttachmentJob is responsible for migrating old attachments to CarrierWave attachments.
  #
  # @param [Work] work The work object to which the attachment belongs. if delete_only, this is the work ID.
  # @param [String] field_name The name of the field where the new attachment will be stored.
  # @param [String] old_attachment_field The name of the field where the old attachment is stored.
  # @param [String] old_attachment_path The file path of the old attachment.
  # @param [Boolean] delete_only If true, only delete the old attachment without migrating.
  class MigrateAttachmentJob < Hyrax::ApplicationJob
    queue_as Hyrax.config.update_slow_queue_name

    def perform(work, field_name, old_attachment_field, old_attachment_path, delete_only: false)
      if delete_only
        Morphosource::AttachmentService.delete(work, old_attachment_field)
        Rails.logger.debug "Deleted old attachment #{old_attachment_path}"
        return
      end
      file = ActionDispatch::Http::UploadedFile.new(
        filename: File.basename(old_attachment_path),
        type: Marcel::MimeType.for(old_attachment_path),
        tempfile: File.open(old_attachment_path)
      )
      work.send("#{field_name}=", file)

      # verify new attachment is present
      new_file_path = Rails.root.join('public').to_s + work.send(field_name)
      if new_file_path.present? && File.exist?(new_file_path)
        Rails.logger.debug "Successfully migrated ##{work.id}: #{field_name} -> #{work.send(field_name)}"
      else
        Rails.logger.debug "Error migrating ##{work.id} #{field_name} attachment"
      end
    end
  end
end