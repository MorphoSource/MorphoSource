module Morphosource::Derivatives
  class GltfScaleError < RuntimeError
  end

  # Derivative tool to interface with gltf-scale CLI utility, used for uniformly scaling GLTF or GLB 3D models
  class GltfScale < DerivativeTool
    attr_reader :source_path, :out_path, :scale
    def initialize(source_path, out_path, scale)
      @source_path = source_path
      @out_path = out_path
      @scale = scale
    end

    def call
      unless File.exists?(source_path)
        raise Morphosource::Derivatives::GltfScaleError.new("Source file: #{source_path} does not exist.")
      end

      internal_call # to do add some output/post-process controls
    end

    protected 
        
    def command
      "gltf-scale '#{source_path}' '#{out_path}' #{scale}"
    end

    # Check for produced derivative file, otherwise raise gltf-scale response as error
    def post_process(raw_output)
      if !File.exists?(out_path) || (File.size(out_path) == 0)
        raise Morphosource::Derivatives::GltfScaleError.new("File not successfully created by derivative tool.\nTool command: \"#{command}\"\nTool output:\n\"#{raw_output}\"")
      end
    end
  end
end
