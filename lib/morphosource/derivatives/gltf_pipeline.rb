module Morphosource::Derivatives
  class GltfPipelineError < RuntimeError
  end

  class GltfPipeline < DerivativeTool
    attr_reader :source_path, :out_path, :separate_textures
    def initialize(source_path, out_path, separate_textures=false)
      @source_path = source_path
      @out_path = out_path
      @separate_textures = separate_textures
    end

    def call
      unless File.exists?(source_path)
        raise Morphosource::Derivatives::GltfPipelineError.new("Source file: #{source_path} does not exist.")
      end

      internal_call # to do add some output/post-process controls
    end

    protected     
      def command
        "gltf-pipeline -i #{source_path} -o #{out_path} -d " +
        ( separate_textures ? "-t" : "" )
      end
  end
end
