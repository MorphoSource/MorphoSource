module Morphosource
  class CwAttachmentService
    attr_reader :object, :field_name

    class << self
      # Create an attachment for a given object
      # @param object [Object] The model instance (e.g., a ProcessingEvent instance)
      # @param field_name [String] The name of the attachment field
      # @param file [File, ActionDispatch::Http::UploadedFile] The file to be attached
      # @param accepted_formats [Array<String>] List of accepted file formats
      # @param save_work [Boolean] save work after attachment is created or deleted
      def create(object, field_name, file, accepted_formats = Morphosource.attachment_formats, save_work = false)
        new(object, field_name).create_attachment(file, accepted_formats, save_work)
      end

      # Delete all attachments for the given object and field name
      # @param object [Object] The model instance
      # @param field_name [String] The name of the attachment field
      def delete(object, field_name)
        new(object, field_name).delete_attachment
      end
    end

    # Initialize with object and field name
    # @param object [Object] The model instance or ID
    # @param field_name [String] The name of the attachment field
    def initialize(object, field_name)
      if object.is_a?(String)
        @object = ActiveFedora::Base.find(object) 
      else 
        @object = object
      end
      @field_name = field_name
    end

    # Create an attachment
    # @param file [File, ActionDispatch::Http::UploadedFile] The file to be attached
    # @param accepted_formats [Array<String>] List of accepted file formats
    def create_attachment(file, accepted_formats, save_work)
      validate_field
      validate_file_format(file, accepted_formats)
      uploader = build_uploader
      uploader.store!(file)
      object.public_send("#{field_name}=", uploader.url)
      object.save if save_work
    end

    def delete_attachment
      validate_field
      attachment_url = object.public_send(field_name)
      return unless attachment_url.present?
      uploader = build_uploader
      file_name = File.basename(attachment_url)
      uploader.retrieve_from_store!(file_name)
      if uploader.file && File.exist?(uploader.file.path)
        Rails.logger.info "Deleting file: #{uploader.file.path}"
        uploader.remove!
      else
        Rails.logger.warn "File not found: #{uploader.file&.path}"
      end
      object.public_send("#{field_name}=", nil)
    end

    private

    # Validate that the field exists on the object
    def validate_field
      unless object.respond_to?(field_name)
        raise ArgumentError, "Field '#{field_name}' does not exist on #{object.class.name}"
      end
    end

    # Validate the file format
    def validate_file_format(file, accepted_formats)
      extension = File.extname(file.original_filename).downcase
      unless accepted_formats.include?(extension)
        raise ArgumentError, "Invalid file format: #{extension}. Accepted formats: #{accepted_formats.join(', ')}"
      end
    end

    # Build the uploader instance
    def build_uploader
      uploader_class = object.attachment_uploader
      uploader = uploader_class.new
      uploader.work_id = object.id
      uploader
    end
  end
end
