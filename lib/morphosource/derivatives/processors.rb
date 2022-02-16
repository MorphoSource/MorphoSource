module Morphosource
  module Derivatives
    module Processors
      extend ActiveSupport::Autoload
      extend Hydra::Derivatives::Processors

      autoload :CroppedImage
      autoload :CTImageSeries
      autoload :Mesh
      autoload :Video
    end
  end
end