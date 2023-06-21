class CalculateFileSetCrc32Job < Hyrax::ApplicationJob
  queue_as Hyrax.config.update_medium_queue_name

  def perform(work_id)
    return unless FileSet.exists?(work_id) &&
                  (file_set = FileSet.find(work_id)).present?

    file_set.original_file.crc32 = calculate_crc32(file_set)
    file_set.original_file.save!
  end

  def calculate_crc32(file_set)
    if file_set.original_file.present?
      crc32 = calculate_file_crc32(file_set)
    elsif file_set.import_url.present?
      crc32 = calculate_remote_file_crc32(file_set)
    end
  end

  def calculate_file_crc32(file_set)
    file = File.open(Hyrax::WorkingDirectory.find_or_retrieve(file_set.original_file.id, file_set.id))
    crc = crc32_from_io(file)
    file.rewind
    crc
  end

  def calculate_remote_file_crc32(file_set)
    file = URI.parse(file_set.import_url).open
    crc = crc32_from_io(file)
    file.close
    file.unlink
    crc
  end

  def crc32_from_io(file)
    Array(ZipTricks::StreamCRC32.from_io(file))
  end
end