class UpdateSingleSpecimenFromIdigbioJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.update_slow_queue_name

  def perform(id, save_work=false, system_update=false, log_file)
    log = log_file.present?? Logger.new(log_file) : Logger.new(STDOUT) 
    if BiologicalSpecimen.exists?(id) 
      BiologicalSpecimen.find(id).update_metadata_from_idigbio_occurrence_id(save_work, system_update, false, log_file)
    end
  end
end
