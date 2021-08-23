module BatchSubmission
  module ConvertedMs1Batch
    module Models
      extend ActiveSupport::Autoload

      autoload :BiologicalSpecimenManifest
      autoload :CombinedProcessingEventMediaManifest
      autoload :ImagingEventManifest
      autoload :MediaIePeManifest
      autoload :TaxonomyManifest
    end
  end
end