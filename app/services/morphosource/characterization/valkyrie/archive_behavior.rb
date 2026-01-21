module Morphosource
  module Characterization
    module Valkyrie
      module ArchiveBehavior
        # Gets representative file from archive and stores it as content.
        # Unlike Morphosource::Works::CharacterizationService, expects source to be a string.
        # todovalk this is probably a problem, likely need to convert Valkyrie::StorageAdapter::StreamFile to file location string
        def archive_to_content
          representative_file_name = nil
          representative_file_io = nil
          recognized_file_count = 0

          archive_service = Morphosource::Files::ArchiveService.new(source)

          # First, try to find a group of >20 image files with most preferred file extension
          file_group, ext = archive_service.largest_file_group(
            image_formats,
            cutoff: 10,
            cutoff_exception_exts: ['.dcm', '.dicom']
          )

          if file_group.present?
            representative_file_name = file_group[file_group.count/2] # take from middle of group for image series
            recognized_file_count = file_group.count
          else
            matching_files = archive_service.all_contents_files
              .select { |f| file_type_priorities.include?(File.extname(f).downcase) }

            representative_file_name = matching_files
              .sort_by { |f| file_type_priorities.index(File.extname(f).downcase)}
              .first
            recognized_file_count = matching_files.count
          end

          # get io stream for representative file
          if representative_file_name.present?
            representative_file_io = archive_service.get_contents_file(representative_file_name)
          end

          return archive_service.all_contents_files,
            representative_file_io,
            representative_file_name,
            recognized_file_count
        end

        def mesh_formats
          ['.glb', '.gltf', '.obj', '.ply', '.stl', '.wrl', '.x3d']
        end

        def image_formats
          ['.dcm', '.dicom', '.tiff', '.tif', '.bmp', '.png', '.jpeg', '.jpg', '.svg', '.dng', '.nef', '.crw', '.cr2', '.cr3', '.iiq', '.arw', '.raw', '.rw2', '.ima', '']
        end

        def file_type_priorities
          mesh_formats + image_formats
        end

        # Extract all archive files to a tmp location
        def extract_representative_content_and_others
          @tmp_dir_path = Rails.root.join(Hyrax.config.derivatives_tmp_path, SecureRandom.uuid)
          Dir.mkdir tmp_dir_path unless File.exist? tmp_dir_path

          extracted_files = Morphosource::Files::ArchiveService.new(source).extract_archive(tmp_dir_path)
          content_path = extracted_files.find { |f| f.include? file_name } # representative file in extracted files
          if content_path
            return open(content_path)
          else
            raise "Previously identified representative file (#{file_name}) not found in archive when extracting files"
          end
        end
      end
    end
  end
end