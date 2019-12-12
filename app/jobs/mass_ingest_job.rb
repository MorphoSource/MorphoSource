class MassIngestJob < ApplicationJob

  queue_as Hyrax.config.ingest_queue_name

  def perform(args)
    Ms1to2::Importer.new(args[:csv_path], args[:update], args[:update_only_if_no_file]).call
  end

end
