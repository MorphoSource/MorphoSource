class ImportUserStatsJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  def perform
    importer = Morphosource::UserStatImporter.new(verbose: true, logging: true)
    importer.import
  end
end
