module MassIngest
  module ConvertedMs1Batch
    extend ActiveSupport::Autoload

    autoload :Factory
    autoload :Models

    autoload :IngestManifest
    autoload :MassIngestHelper
    autoload :ValidateManifest
  end
end