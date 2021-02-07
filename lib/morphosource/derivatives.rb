module Morphosource
  module Derivatives
    extend ActiveSupport::Concern
    extend ActiveSupport::Autoload
    extend Hydra::Derivatives

    autoload :MeshDerivatives
    autoload :CTImageSeriesDerivatives
    autoload :CroppedImageDerivatives
    autoload :Processors

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