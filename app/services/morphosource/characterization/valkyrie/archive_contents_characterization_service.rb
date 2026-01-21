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


