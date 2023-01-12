class RenameFileJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.update_slow_queue_name

  def perform(fileset_id, new_filename)
    if (
        FileSet.exists?(fileset_id) && 
        (fs = FileSet.find(fileset_id)).present? && 
        fs.original_file.present?
    )
    fs.label = new_filename
    fs.title = [new_filename]
    fs.original_file.file_name = [new_filename]
    fs.original_file.save!
    fs.save!
    end
  end
end
