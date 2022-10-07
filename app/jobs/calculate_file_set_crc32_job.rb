class CalculateFileSetCrc32Job < Hyrax::ApplicationJob
  queue_as Hyrax.config.update_medium_queue_name

  def perform(work_id)
    if FileSet.exists?(work_id) && (fs = FileSet.find(work_id)).present? && (file = fs.original_file).present?
      crc = ZipTricks::StreamCRC32.new
      file.stream.each { |chunk| crc << chunk }
      file_crc32 = crc.to_i
      if file_crc32.present?
        file.crc32 = [file_crc32]
        file.save!
      end
    end
  end
end