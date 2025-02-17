module Morphosource
  #
  # RollbackMigrateAttachmentJob is responsible for migrating old attachments to CarrierWave attachments.
  #
  # @param [model_name] The name of the model class to which the attachment belongs.
  # @param [id] The ID of the object to which the attachment belongs.
  # @param [String] field_name The name of the field where the new attachment will be stored.
  # @param [String] old_attachment_field The name of the field where the old attachment is stored.
  # @param [String] old_attachment_path The file path of the old attachment.
  # @param [Boolean] no_delete, if true, the CW attachment will not be deleted.
  class RollbackMigrateAttachmentJob < Hyrax::ApplicationJob
    queue_as Hyrax.config.update_slow_queue_name

    def perform(model_name, id, field_name, old_attachment_field, old_attachment_path, no_delete)
      begin
        model_class = model_name.constantize
      rescue StandardError => e
        puts "Error resolving model '#{model_name}': #{e.message}"
        return
      end
      obj = model_class.find(id)
      return unless obj.present? 
      cw_path = Rails.root.join('public').to_s + obj.send(field_name) 
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

      Morphosource::AttachmentService.create(obj.id, old_attachment_field, file, obj.send("#{field_name}_formats"))

      old_attachment_path = Morphosource::AttachmentService.get(obj.id, old_attachment_field)
      if old_attachment_path.present?
        puts "Old attachmemnt created for ##{obj.id}: #{old_attachment_field} -> #{old_attachment_path}"
      else
        puts "Failed to create Old attachmemnt for ##{obj.id}: #{old_attachment_field}"              
      end

      unless no_delete
        obj.send("#{field_name}=", nil)
      end      

    end
  end
end