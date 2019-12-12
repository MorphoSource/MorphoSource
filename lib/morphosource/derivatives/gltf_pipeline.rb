module Morphosource::Derivatives
  class GltfPipelineError < RuntimeError
  end

  class GltfPipeline < DerivativeTool
    attr_reader :source_path, :out_path
    def initialize(source_path, out_path)
      @source_path = source_path
      @out_path = out_path
    end

    def call
      unless File.exists?(source_path)
        raise Morphosource::Derivatives::GltfPipelineError.new("Source file: #{source_path} does not exist.")
      end

      internal_call # to do add some output/post-process controls
    end

    protected     
      def command
        "gltf-pipeline -i #{source_path} -o #{out_path} -d"
      end
  end
end
