require 'hydra/works/services/crc32_characterization_service.rb'
require 'hydra/works/services/archive_contents_characterization_service.rb'

class CharacterizeJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.heavy_queue_name

  # Characterizes the file at 'filepath' if available, otherwise, pulls a copy from the repository
  # and runs characterization on that file.
  # @param [FileSet] file_set
  # @param [String] file_id identifier for a Hydra::PCDM::File
  # @param [String, NilClass] filepath the cached file within the Hyrax.config.working_path
  def perform(file_set, file_id, filepath = nil)
    raise "#{file_set.class.characterization_proxy} was not found for FileSet #{file_set.id}" unless file_set.characterization_proxy?
    filepath = Hyrax::WorkingDirectory.find_or_retrieve(file_id, file_set.id) unless filepath && File.exist?(filepath)

    # Calculate Crc32, needed for file download
    CharacterizeCrc32Job.perform_later(file_set, file_id, filepath)

    # Generic file characterization based on FITS applied to the upload's single file
    # Want to run this on all uploads, to get basic file info
    
    Rails.logger.debug "Running FITS characterization on #{file_set.characterization_proxy.id} (#{file_set.characterization_proxy.mime_type})"
    Hydra::Works::CharacterizationService.run(file_set.characterization_proxy, filepath)
    Rails.logger.debug "Ran FITS characterization on #{file_set.characterization_proxy.id} (#{file_set.characterization_proxy.mime_type})"

    file_set.characterization_proxy.save!
    file_set.update_index
    file_set.parent&.in_collections&.each(&:update_index)
    Morphosource::Works::FileSetCharacterizationParentUpdateService.run(file_set)

    # Specialized file characterization for meshes or to process representative file for archive
    # For mesh files, gltf-inspect/blender overwrites mime type output from FITS

    begin
      ext = File.extname(filepath)
      if (ext =~ /\.(glb|gltf)$/)
        gltf_inspect_options = {
          "parser_class" => Hydra::Works::Characterization::BlenderDocument, 
          "tool_class" => :gltf_inspect
        }
        Rails.logger.debug "Running gltf-inspect characterization on #{file_set.characterization_proxy.id} (#{file_set.characterization_proxy.mime_type})"
        Hydra::Works::CharacterizationService.run(file_set.characterization_proxy, filepath, gltf_inspect_options)
        Rails.logger.debug "Ran gltf-inspect characterization on #{file_set.characterization_proxy.id} (#{file_set.characterization_proxy.mime_type})"
      elsif (ext =~ /\.(obj|ply|stl|wrl|x3d)$/)
        Rails.logger.debug "Running Blender characterization on #{file_set.characterization_proxy.id} (#{file_set.characterization_proxy.mime_type})"
        Hydra::Works::CharacterizationService.run(file_set.characterization_proxy, filepath, blender_options)
        Rails.logger.debug "Ran Blender characterization on #{file_set.characterization_proxy.id} (#{file_set.characterization_proxy.mime_type})"
      elsif (ext =~ /\.(zip|tar)$/)
        Rails.logger.debug "Running archive contents characterization on #{file_set.characterization_proxy.id} (#{file_set.characterization_proxy.mime_type})"
        Hydra::Works::ArchiveContentsCharacterizationService.run(file_set.characterization_proxy, filepath)
        Rails.logger.debug "Ran archive contents characterization on #{file_set.characterization_proxy.id} (#{file_set.characterization_proxy.mime_type})"
      end
    ensure
      file_set.characterization_proxy.save!
      file_set.update_index
      file_set.parent&.in_collections&.each(&:update_index)
      Morphosource::Works::FileSetCharacterizationParentUpdateService.run(file_set)
    end
    
    CreateDerivativesJob.perform_later(file_set, file_id, filepath)
  end

  def blender_options
    {
      "parser_class" => Hydra::Works::Characterization::BlenderDocument, 
      "tool_class" => ( Hyrax.config.skip_pymeshlab_characterization ? :blender : :pymeshlab )
    }
  end
end

class CharacterizeCrc32Job < Hyrax::ApplicationJob
  queue_as Hyrax.config.heavy_queue_name

  def perform(file_set, file_id, filepath = nil)
    raise "#{file_set.class.characterization_proxy} was not found for FileSet #{file_set.id}" unless file_set.characterization_proxy?
    filepath = Hyrax::WorkingDirectory.find_or_retrieve(file_id, file_set.id) unless filepath && File.exist?(filepath)

    Rails.logger.debug "Running CRC32 characterization on #{file_set.characterization_proxy.id} (#{file_set.characterization_proxy.mime_type})"
    Hydra::Works::Crc32CharacterizationService.run(file_set.characterization_proxy, filepath)
    Rails.logger.debug "Ran CRC32 characterization on #{file_set.characterization_proxy.id} (#{file_set.characterization_proxy.mime_type})"

    file_set.characterization_proxy.save!
    file_set.update_index
    file_set.parent&.in_collections&.each(&:update_index)
  end
end