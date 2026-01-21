# frozen_string_literal: true
module Valkyrie
  class CharacterizationJob < HeavyJob
    class_attribute :characterization_service
    self.characterization_service = Hyrax.config.characterization_service

    class_attribute :characterization_options
    self.characterization_options = Hyrax.config.characterization_options

    def perform(file_metadata_id)
      file_metadata = Hyrax.custom_queries.find_file_metadata_by(id: file_metadata_id)

      # In CharacterizeJob, first step is to ensure a working copy of the file is present, but
      # that's not used in Hyrax VCJ. Proceed without it for now, but may need later with S3 (todovalk)

      characterize(file_metadata)
    end

    # Perform multiple characterization steps, persisting file metadata at each step
    def characterize(file_metadata)
      # Calculate Crc32, needed for file download
      ValkyrieCharacterizeCrc32Job.perform_later(file_metadata_id)

      # Generic file characterization based on FITS applied to the upload's single file
      # Want to run this on all uploads, to get basic file info
      Rails.logger.debug "Running FITS characterization on #{file_metadata.id} (#{file_metadata.mime_type})"
      file_metadata = run_characterization(file_metadata)

      # todovalk Morphosource::Works::FileSetCharacterizationParentUpdateService.run(file_set)

      # Specialized file characterization for meshes or to process representative file for archive
      # For mesh files, gltf-inspect/blender overwrites mime type output from FITS

      ext = (File.extname(file_metadata.file_identifier) || "").downcase
      if (ext =~ /\.(glb|gltf)$/)
        Rails.logger.debug "Running gltf-inspect characterization on #{file_metadata.id} (#{file_metadata.mime_type})"
        file_metadata = run_characterization(file_metadata, gltf_inspect_options)
      elsif (ext =~ /\.(obj|ply|stl|wrl|x3d)$/)
        Rails.logger.debug "Running Blender characterization on #{file_metadata.id} (#{file_metadata.mime_type})"
        file_metadata = run_characterization(file_metadata, blender_options)
      elsif (ext =~ /\.(zip|tar)$/)
        Rails.logger.debug "Running archive contents characterization on #{file_metadata.id} (#{file_metadata.mime_type})"
        Hydra::Works::ArchiveContentsCharacterizationService.run(file_set.characterization_proxy, filepath) #todovalk
      end

      # todovalk Morphosource::Works::FileSetCharacterizationParentUpdateService.run(file_set)

      # Emit event signaling characterization is complete, triggering create derivatives job
      Hyrax.publisher.publish(
        'file.characterized',
        file_set: Hyrax.query_service.find_by(id: file_metadata.file_set_id),
        file_id: file_metadata.id.to_s,
        path_hint: file_metadata.file_identifier.to_s
      )
    end

    def run_characterization(file_metadata, extra_options = {})
      characterization_service.run(
        metadata: file_metadata,
        file: file_metadata.file,
        publish_characterized: false,
        characterization_options.merge(extra_options)
      )
    end

    def characterization_service
      self.class.characterization_service
    end

    def characterization_options
      self.class.characterization_options
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