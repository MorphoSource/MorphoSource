module BatchSubmission
  module ConvertedMs1Batch
    extend ActiveSupport::Autoload

    autoload :Factory
    autoload :Models

    autoload :Manifest
    autoload :BatchSubmissionHelper
    autoload :ValidateManifest
  end
end