module Morphosource
  module Derivatives
    module Processors
      extend ActiveSupport::Autoload
      extend Hydra::Derivatives::Processors

      autoload :CroppedImage
      autoload :CTImageSeries
      autoload :ImageSeriesCroppedImage
      autoload :ImageSeriesUtil
      autoload :Mesh
      autoload :MeshGltf
      autoload :Video
    end
  end
end