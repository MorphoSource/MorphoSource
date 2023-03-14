module BatchSubmissionsImporter
  module Factory
    class MediaFactory < ObjectFactory
      include WithAssociatedCollection

      self.klass = Media

      def remote_files
        files.map do |file_name|
          if files_directory == :is_remote
            { url: "#{file_name}", file_name: File.basename(file_name) } # for URLs
          else
            { url: "file:#{file_name}", file_name: File.basename(file_name) } # for local files
          end
        end
      end

    end
  end
end
