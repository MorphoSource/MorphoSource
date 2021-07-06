module MassIngest
  module ConvertedMs1Batch
    extend ActiveSupport::Autoload

    autoload :Factory
    autoload :Models

    autoload :Manifest
    autoload :MassIngestHelper
    autoload :ValidateManifest
  end
end