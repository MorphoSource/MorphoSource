module Morphosource
  class AttachmentService
    attr_reader :id, :field_name

    class << self
      def create(object, field_name, file)
        new(object, field_name).create_attachment(file)
      end

      def create_copy(object, field_name, source_object)
        new(object, field_name).create_attachment_from_copy(source_object)
      end

      def get(object, field_name)
        new(object, field_name).get
      end

      def delete(object, field_name)
        new(object, field_name).delete_all_attachments
      end
    end

    def initialize(object, field_name)
      @id = object.is_a?(String) ? object : object.id
      @field_name = field_name
    end

    def create_attachment(file)
      if file.is_a? String # string path case
        file_name = File.basename(file)
        file_path = file
        tempfile = false
      elsif Morphosource.attachment_formats.include?(File.extname(file.original_filename)) # tempfile case
        file_name = file.original_filename
        file_path = file.tempfile.path
        tempfile = true
      else
        raise 'Unacceptable file format for attachment creation'
      end

      extension = File.extname(file_name).delete('.')
      attachment_path = Morphosource::AttachmentPath.attachment_path_for_reference(id, field_name, extension)

      FileUtils.rm attachment_path if File.exists?(attachment_path)
      FileUtils.mkdir_p(File.dirname(attachment_path))

      begin 
        FileUtils.cp file_path, attachment_path
      ensure
        file.tempfile.close if tempfile
        file.tempfile.unlink if tempfile
      end
    end

    def create_attachment_from_copy(source_object)
      source_id = source_object.is_a?(String) ? source_object : source_object.id
      source_attachment = Morphosource::AttachmentPath.attachments_for_reference(source_id).find { |p| p.include? field_name }
      create_attachment(source_attachment) if source_attachment.present? && File.exists?(source_attachment)
    end

    def delete_all_attachments
      Morphosource::AttachmentPath.attachments_for_reference(id).
        select { |p| p.include? field_name }.
        each { |p| FileUtils.rm p }
    end

    def get
      Morphosource::AttachmentPath.attachments_for_reference(id).find { |p| p.include? field_name }
    end
  end
end
