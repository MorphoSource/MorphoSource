module Morphosource
  module Derivatives
    class MeshObjDerivatives < MeshDerivatives
      def self.processor_class
        ::Morphosource::Derivatives::Processors::MeshObj
      end
    end
  end
end