class CalculateFileSetCrc32Job < Hyrax::ApplicationJob
  queue_as Hyrax.config.update_slow_queue_name

  def perform(work_id)
    if FileSet.exists?(work_id) && (fs = FileSet.find(work_id)).present? && (file = fs.original_file).present?
      crc = ZipTricks::StreamCRC32.new
      file.stream.each { |chunk| crc << chunk }
      crc.to_i
    end
  end
end