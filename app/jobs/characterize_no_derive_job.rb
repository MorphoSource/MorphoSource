# This exists for a small subset of works where we want to characterize but not derive
# Should only be called directly via console, not automatically used for any works

require 'hydra/works/services/crc32_characterization_service.rb'
require 'hydra/works/services/archive_contents_characterization_service.rb'

class CharacterizeNoDeriveJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.heavy_queue_name

  # Characterizes the file at 'filepath' if available, otherwise, pulls a copy from the repository
  # and runs characterization on that file.
  # @param [FileSet] file_set
  # @param [String] file_id identifier for a Hydra::PCDM::File
  # @param [String, NilClass] filepath the cached file within the Hyrax.config.working_path
  def perform(file_set, file_id, filepath = nil)
    raise "#{file_set.class.characterization_proxy} was not found for FileSet #{file_set.id}" unless file_set.characterization_proxy?
    filepath = Hyrax::WorkingDirectory.find_or_retrieve(file_id, file_set.id) unless filepath && File.exist?(filepath)
    # Run FITS , then blender (if it is a mesh file type).  
    # For mesh files:
    # - we want blender to overwrite the mime type output from FITS
    # - we still want to run FITS to get basic file info (e.g. checksum)
    Rails.logger.debug "Running FITS characterization on #{file_set.characterization_proxy.id} (#{file_set.characterization_proxy.mime_type})"
    Hydra::Works::CharacterizationService.run(file_set.characterization_proxy, filepath)
    Rails.logger.debug "Ran FITS characterization on #{file_set.characterization_proxy.id} (#{file_set.characterization_proxy.mime_type})"

    # Calculate CRC32 for file
    Rails.logger.debug "Running CRC32 characterization on #{file_set.characterization_proxy.id} (#{file_set.characterization_proxy.mime_type})"
    Hydra::Works::Crc32CharacterizationService.run(file_set.characterization_proxy, filepath)
    Rails.logger.debug "Ran CRC32 characterization on #{file_set.characterization_proxy.id} (#{file_set.characterization_proxy.mime_type})"

    begin
      ext = File.extname(filepath)
      if (ext =~ /\.(glb|gltf|obj|ply|stl|wrl|x3d)$/)
        blender_options = {
          "parser_class" => Hydra::Works::Characterization::BlenderDocument, 
          "tool_class" => :blender
        }
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
    end
    
    Morphosource::Works::FileSetCharacterizationParentUpdateService.run(file_set)
  end
end