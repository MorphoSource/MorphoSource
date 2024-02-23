module Morphosource
  module Derivatives
    class MeshGltfDerivatives < MeshDerivatives
      def self.processor_class
        ::Morphosource::Derivatives::Processors::MeshGltf 
      end
    end
  end
end