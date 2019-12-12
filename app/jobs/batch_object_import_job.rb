class BatchObjectImportJob < ApplicationJob

  queue_as Hyrax.config.ingest_queue_name

  def perform(model, attributes, files_directory, update = false)
    Importer::BatchObjectImporter.call(model, attributes, files_directory, update)
  end

end
