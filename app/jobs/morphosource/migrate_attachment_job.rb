module Morphosource
  #
  # MigrateAttachmentJob is responsible for migrating old attachments to CarrierWave attachments.
  #
  # @param [model_name] The name of the model class to which the attachment belongs.
  # @param [id] The ID of the object to which the attachment belongs.
  # @param [String] field_name The name of the field where the new attachment will be stored.
  # @param [String] old_attachment_field The name of the field where the old attachment is stored.
  # @param [String] old_attachment_path The file path of the old attachment.
  # @param [Boolean] delete_only If true, only delete the old attachment without migrating.
  class MigrateAttachmentJob < Hyrax::ApplicationJob
    queue_as Hyrax.config.update_slow_queue_name

    def perform(model_name, id, field_name, old_attachment_field, old_attachment_path, delete_only: false)
      begin
        model_class = model_name.constantize
      rescue StandardError => e
        puts "Error resolving model '#{model_name}': #{e.message}"
        return
      end
      obj = model_class.find(id)
      return unless obj.present? 
      if delete_only
        Morphosource::AttachmentService.delete(obj, old_attachment_field)
        Rails.logger.debug "Deleted old attachment #{old_attachment_path}"
        return
      end
      file = ActionDispatch::Http::UploadedFile.new(
        filename: File.basename(old_attachment_path),
        type: Marcel::MimeType.for(old_attachment_path),
        tempfile: File.open(old_attachment_path)
      )
      obj.send("#{field_name}=", file)

      # verify new attachment is present
      new_file_path = Rails.root.join('public').to_s + obj.send(field_name)
      if new_file_path.present? && File.exist?(new_file_path)
        Rails.logger.debug "Successfully migrated ##{obj.id}: #{field_name} -> #{obj.send(field_name)}"
      else
        Rails.logger.debug "Error migrating ##{obj.id} #{field_name} attachment"
      end
    end
  end
end