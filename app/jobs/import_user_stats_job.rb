class ImportUserStatsJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  def perform(number_of_retries = 0)
    importer = Morphosource::UserStatImporter.new(verbose: true, logging: true, number_of_retries: number_of_retries)
    importer.import
  end
end
