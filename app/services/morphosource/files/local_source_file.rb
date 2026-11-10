# frozen_string_literal: true

module Morphosource
  module Files
    # Local path for a stored file; S3 tmp files get the original extension, since tools pick formats by it.
    module LocalSourceFile
      # @param file [Valkyrie::StorageAdapter::File] file returned by a storage adapter
      # @param original_filename [String] supplies the extension for S3 tmp files
      # @return [String]
      def self.path(file, original_filename)
        path = file.disk_path.to_s
        return path unless file.is_a?(Valkyrie::StorageAdapter::StreamFile)

        ext = ::File.extname(original_filename.to_s)
        return path if ext.blank? || ::File.extname(path).present?

        ::File.rename(path, "#{path}#{ext}")
        "#{path}#{ext}"
      end
    end
  end
end
