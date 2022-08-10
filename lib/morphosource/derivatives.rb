module Morphosource
  module Derivatives
    extend ActiveSupport::Concern
    extend ActiveSupport::Autoload
    extend Hydra::Derivatives

    autoload :CroppedImageDerivatives
    autoload :CTImageSeriesCroppedImageDerivatives
    autoload :CTImageSeriesDerivatives
    autoload :MeshDerivatives
    autoload :VideoDerivatives

    autoload :Processors

    autoload :Alembic
    autoload :Blender
    autoload :Dcmcjpeg
    autoload :Dcmdjpeg
    autoload :Dcmj2pnm
    autoload :DerivativeTool
    autoload :Fiji
    autoload :GltfPipeline
    autoload :Img2dcm

    def self.blender_path
      Hyrax.config.blender_path
    end

    def self.fiji_path
      Hyrax.config.fiji_path
    end

    def self.python_path
        Hyrax.config.python_path
    end
  end
end