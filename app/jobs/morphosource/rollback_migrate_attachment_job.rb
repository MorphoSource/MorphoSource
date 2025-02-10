module Morphosource
  #
  # RollbackMigrateAttachmentJob is responsible for migrating old attachments to CarrierWave attachments.
  #
  # @param [Work] work The work object to which the attachment belongs. if delete_only, this is the work ID.
  # @param [String] field_name The name of the field where the new attachment will be stored.
  # @param [String] old_attachment_field The name of the field where the old attachment is stored.
  # @param [String] old_attachment_path The file path of the old attachment.
  # @param [Boolean] no_delete, if true, the CW attachment will not be deleted.
  class RollbackMigrateAttachmentJob < Hyrax::ApplicationJob
    queue_as Hyrax.config.update_slow_queue_name

    def perform(work, field_name, old_attachment_field, old_attachment_path, no_delete)
      cw_path = Rails.root.join('public').to_s + work.send(field_name) 
      return unless cw_path.present? && File.exist?(cw_path)

      cw_file = File.open(cw_path)
      tempfile = Tempfile.new(File.basename(cw_file.path))
      tempfile.write(cw_file.read)
      tempfile.rewind
      tempfile.close

      file = ActionDispatch::Http::UploadedFile.new(
        filename: File.basename(cw_path),
        type: Marcel::MimeType.for(cw_path),
        tempfile: tempfile
      )

      Morphosource::AttachmentService.create(work.id, old_attachment_field, file, work.send("#{field_name}_formats"))

      old_attachment_path = Morphosource::AttachmentService.get(work.id, old_attachment_field)
      if old_attachment_path.present?
        puts "Old attachmemnt created for ##{work.id}: #{old_attachment_field} -> #{old_attachment_path}"
      else
        puts "Failed to create Old attachmemnt for ##{work.id}: #{old_attachment_field}"              
      end

      unless no_delete
        work.send("#{field_name}=", nil)
      end      

    end
  end
end