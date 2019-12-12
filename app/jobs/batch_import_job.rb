class BatchImportJob < ApplicationJob

  queue_as Hyrax.config.ingest_queue_name

  def perform(args)
    importer = Importer::CSVImporter.new(args[:manifest_file],
                                         args[:files_directory],
                                         model: args[:model],
                                         checksum_file: args[:checksum_file],
                                         depositor: args[:user],
                                         on_behalf_of: args[:on_behalf_of])
    importer.import_all
  end

end
