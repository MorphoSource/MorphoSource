module Morphosource
  module Characterization
    module Valkyrie
      # Characterize information about archive contents and single representative file from archive
      class ArchiveContentsCharacterizationService < CharacterizationService

        attr_accessor :content, :file_name, :accepted_file_count, :all_files, :tmp_dir_path

        # todovalk remove this but reminder for now
        # def initialize(object, source, options)
        #   @object       = object
        #   @source       = source
        #   @mapping      = options.fetch(:parser_mapping, Hydra::Works::Characterization.mapper)
        #   @parser_class = options.fetch("parser_class", Hydra::Works::Characterization::FitsDocument)
        #   @tools        = options.fetch("tool_class", :fits)
        #   @sub_object = Hydra::PCDM::File.new()
        # end

        def characterize
          # Store original fields for archive that may be overwritten for representative file
          original_mime_type = metadata.mime_type
          original_file_size = metadata.file_size
          original_file_name = metadata.original_filename

          # Peek inside of archives
          # Content and file_name normally refer to ingested file, but here refer to representative file in archive
          @all_files, @content, @file_name, @accepted_file_count = archive_to_content

          # Extract metadata
          if file_name.present? && content.present?
            # Special handling for meshes
            options = {}
            if blender_mesh_file_types.include? File.extname(file_name).downcase
              # Use Blender instead of FITS for characterization
              options = blender_options
            elsif gltf_inspect_mesh_file_types.include? File.extname(file_name).downcase
              # Extract all files to temp location and use gltf-inspect instead of FITS for characterization
              if File.extname(file_name).downcase == '.gltf'
                @needs_cleanup = true
                @content = extract_representative_content_and_others
              end
              options = gltf_inspect_options
            end

            # Set representative file name so FITS temp file gets the correct extension
            metadata.original_filename = file_name

            # Run characterization against representative file and persist on file metadata
            # Either FITS, gltf_inspect, blender, or pymeshlab is run depending on file type and config
            Hyrax.config.characterization_service.new(
              metadata: metadata,
              file: content,
              **options
            ).characterize
          end

          apply_special_fields
          metadata.mime_type = original_mime_type
          metadata.file_size = original_file_size
          metadata.original_filename = original_file_name
        ensure
          cleanup_tmp_files if @needs_cleanup
        end

        def apply_special_fields
          metadata.contents_accepted_file_count = accepted_file_count
          metadata.contents_all_files = all_files&.to_json || "[]"

          if file_name.present?
            metadata.contents_file_name = file_name
            metadata.contents_mime_type = metadata.mime_type
            metadata.contents_file_size = metadata.file_size
          else
            metadata.contents_mime_type = nil
          end
        end

        # In special GLTF case that all archive files are extracted, delete files after characterization
        def cleanup_tmp_files
          begin
            FileUtils.rm_r tmp_dir_path
          rescue Errno::ENOTEMPTY
            Rails.logger.debug "in cleanup_tmp_files: Directory '#{tmp_dir_path}' not empty."
          end
        end

        # Archive file handling

        # Gets representative file from archive and stores it as content.
        # Handles both file path strings and Valkyrie::StorageAdapter::StreamFile objects.
        def archive_to_content
          representative_file_name = nil
          representative_file_io = nil
          recognized_file_count = 0

          archive_service = Morphosource::Files::ArchiveService.new(source_file_path)

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

        # Helper method to get file path from source (handles both strings and storage adapter files)
        def source_file_path
          if source.respond_to?(:disk_path)
            source.disk_path.to_s
          elsif source.respond_to?(:io) && source.io.respond_to?(:path)
            source.io.path.to_s
          elsif source.is_a?(String)
            source
          else
            raise "Cannot determine file path from source: #{source.class}"
          end
        end

        # Extract all archive files to a tmp location
        def extract_representative_content_and_others
          @tmp_dir_path = Rails.root.join(Hyrax.config.derivatives_tmp_path, SecureRandom.uuid)
          Dir.mkdir tmp_dir_path unless File.exist? tmp_dir_path

          extracted_files = Morphosource::Files::ArchiveService.new(source_file_path).extract_archive(tmp_dir_path)
          content_path = extracted_files.find { |f| f.include? file_name } # representative file in extracted files
          if content_path
            return open(content_path)
          else
            raise "Previously identified representative file (#{file_name}) not found in archive when extracting files"
          end
        end

        # Utility methods

        def gltf_inspect_mesh_file_types
          ['.glb', '.gltf']
        end

        def blender_mesh_file_types
          ['.obj', '.ply', '.stl', '.wrl', '.x3d']
        end

        def gltf_inspect_options
          {
            parser: Hydra::Works::Characterization::BlenderDocument.new,
            ch12n_tool: :gltf_inspect
          }
        end

        def blender_options
          {
            parser: Hydra::Works::Characterization::BlenderDocument.new,
            ch12n_tool: Hyrax.config.skip_pymeshlab_characterization ? :blender : :pymeshlab
          }
        end
      end
    end
  end
end


