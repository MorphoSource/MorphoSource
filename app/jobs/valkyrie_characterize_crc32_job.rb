# frozen_string_literal: true
class ValkyrieCharacterizeCrc32Job < HeavyJob
  def perform(file_metadata_id)
    file_metadata = Hyrax.custom_queries.find_file_metadata_by(id: file_metadata_id)

    Rails.logger.debug "Running CRC32 characterization on #{file_metadata.id} (#{file_metadata.mime_type})"

    # Calculate CRC32 from file stream
    file = file_metadata.file
    crc32 = calculate_crc32(file)

    # Update file metadata with CRC32
    file_metadata.crc32 = crc32
    saved_metadata = Hyrax.persister.save(resource: file_metadata)

    Rails.logger.debug "Completed CRC32 characterization on #{saved_metadata.id}: #{crc32}"

    # Publish metadata update event
    Hyrax.publisher.publish('file.metadata.updated', metadata: saved_metadata, user: ::User.system_user)

    saved_metadata
  end

  private

  def calculate_crc32(file)
    # file is a Valkyrie::StorageAdapter::File; stream delegates to the underlying io.
    # Both local (StreamFile) and remote (LazyHTTPFile) ios implement each.
    crc32_calculator = ZipTricks::StreamCRC32.new
    file.stream.each { |chunk| crc32_calculator << chunk }
    crc32_calculator.to_i
  end
end
