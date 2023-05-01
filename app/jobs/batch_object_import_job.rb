class BatchObjectImportJob < Morphosource::ApplicationJobWithStatus

  queue_as Hyrax.config.mass_ingest_queue_name

  def perform(model, attributes, files_directory, update = false)
    object = BatchSubmissionsImporter::BatchObjectImporter.call(model, attributes, files_directory, update)
    status.update(id: object.id)
  end

end
