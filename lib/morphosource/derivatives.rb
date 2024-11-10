module Morphosource
  module Derivatives
    extend ActiveSupport::Concern
    extend ActiveSupport::Autoload
    extend Hydra::Derivatives

    autoload :CroppedImageDerivatives
    autoload :CTImageSeriesDerivatives
    autoload :ImageSeriesCroppedImageDerivatives
    autoload :MeshDerivatives
    autoload :MeshGltfDerivatives
    autoload :VideoDerivatives

    autoload :Processors

    autoload :Alembic
    autoload :Blender
    autoload :CompressZip
    autoload :Dcmcjpeg
    autoload :Dcmdjpeg
    autoload :Dcmj2pnm
    autoload :DerivativeTool
    autoload :Extract7Zip
    autoload :Fiji
    autoload :GltfPipeline
    autoload :GltfScale
    autoload :GltfTransform
    autoload :Img2dcm
    autoload :Obj2gltf

    def self.blender_path
      Hyrax.config.blender_path
    end

    def self.fiji_script_command
      Hyrax.config.fiji_script_command
    end

    def self.fiji_path
      Hyrax.config.fiji_path
    end

    def self.python_path
        Hyrax.config.python_path
    end
  end
end