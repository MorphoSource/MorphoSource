module Morphosource
  module Derivatives
    class MeshThumbnailDerivatives < Hydra::Derivatives::Runner
      def self.processor_class
        ::Morphosource::Derivatives::Processors::MeshThumbnail
      end
    end
  end
end