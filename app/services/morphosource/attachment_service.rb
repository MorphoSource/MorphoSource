module Morphosource
  class AttachmentService
    attr_reader :id, :field_name

    class << self
      def create(object, field_name, file)
        new(object, field_name).create_attachment(file)
      end

      def get(object, field_name)
        new(object, field_name).get
      end
    end

    def initialize(object, field_name)
      @id = object.is_a?(String) ? object : object.id
      @field_name = field_name
    end

    def create_attachment(file)
      if Morphosource.attachment_formats.include?(File.extname(file.original_filename))
        extension = File.extname(file.original_filename).delete('.')
        attachment_path = Morphosource::AttachmentPath.attachment_path_for_reference(id, field_name, extension)

        FileUtils.rm attachment_path if File.exists?(attachment_path)
        FileUtils.mkdir_p(File.dirname(attachment_path))

        begin 
          FileUtils.cp file.tempfile.path, attachment_path
        ensure
          file.tempfile.close
          file.tempfile.unlink
        end
      else
        raise 'Unacceptable file format for attachment creation'
      end
    end

    def get
      Morphosource::AttachmentPath.attachments_for_reference(id).find { |p| p.include? field_name }
    end
  end
end
