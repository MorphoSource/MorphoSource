module Morphosource
  class AttachmentPath
    attr_reader :id, :field_name, :type_name

    class << self
      # Path on file system where attachment file is stored
      # @param [ActiveFedora::Base or String] object either the AF object or its id
      # @param [String] field_name, metadata field associated
      # @param [String] type_name, one of docx, pdf, or txt
      def attachment_path_for_reference(object, field_name, type_name)
        new(object, field_name, type_name).attachment_path
      end

      # @param [ActiveFedora::Base or String] object either the AF object or its id
      # @return [Array<String>] Array of paths to attachments for this object.
      def attachments_for_reference(object)
        new(object).all_paths
      end
    end

    # @param [ActiveFedora::Base or String] object either the AF object or its id
    # @param [String] field_name, metadata field associated
    # @param [String] type_name, one of docx, pdf, or txt
    def initialize(object, field_name, type_name)
      @id = object.is_a?(String) ? object : object.id
      @field_name = field_name
      @type_name = type_name
    end

    def attachment_path
      "#{path_prefix}-#{file_name}"
    end

    def all_paths
      Dir.glob(root_path.join("*")).select do |path|
        path.start_with?(path_prefix.to_s)
      end
    end

    private

      # @return [String] Returns the root path where attachments will be generated into.
      def root_path
        Pathname.new(attachment_path).dirname
      end

      # @return <Pathname> Full prefix of the path for object.
      def path_prefix
        Pathname.new(Hyrax.config.attachments_path).join(pair_path)
      end

      def pair_path
        id.split('').each_slice(2).map(&:join).join('/')
      end

      def file_name
        return unless field_name && type_name
        "#{field_name.downcase}.#{type_name.downcase}"
      end
  end
end
