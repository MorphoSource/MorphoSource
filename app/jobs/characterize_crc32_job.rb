require 'hydra/works/services/crc32_characterization_service.rb'
require 'hydra/works/services/archive_contents_characterization_service.rb'

class CharacterizeCrc32Job < HeavyJob
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