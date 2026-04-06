class BatchObjectImportJob < Morphosource::ApplicationJobWithStatus

  queue_as Hyrax.config.mass_ingest_queue_name

  def perform(model, attributes, files_directory, update = false, background_job_id = nil, created_objects_key = nil)
    object = BatchSubmissionsImporter::BatchObjectImporter.call(model, attributes, files_directory, update)
    status.update(id: object.id&.to_s)
    if background_job_id.present? && created_objects_key.present?
      BackgroundJob.find(background_job_id).update_created_objects({ created_objects_key => object.id.to_s })
    end
  end

end
