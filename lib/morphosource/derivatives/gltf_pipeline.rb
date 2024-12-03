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
      unless File.exist?(source_path)
        raise Morphosource::Derivatives::GltfPipelineError.new("Source file: #{source_path} does not exist.")
      end

      internal_call # to do add some output/post-process controls
    end

    protected 
        
    def command
      "gltf-pipeline -i '#{source_path}' -o '#{out_path}' -d"
    end

    # Check for produced derivative file, otherwise raise gltf-pipeline response as error
    def post_process(raw_output)
      if !File.exist?(out_path) || (File.size(out_path) == 0)
        raise Morphosource::Derivatives::GltfPipelineError.new("File not successfully created by derivative tool.\nTool command: \"#{command}\"\nTool output:\n\"#{raw_output}\"")
      end
    end
  end
end
