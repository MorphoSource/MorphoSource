module Morphosource::Derivatives
  class Obj2gltfError < RuntimeError
  end

  # Derivative tool to convert OBJ meshes to GLB format
  class Obj2gltf < DerivativeTool
    attr_reader :source_path, :out_path
    def initialize(source_path, out_path)
      @source_path = source_path
      @out_path = out_path
    end

    def call
      unless File.exist?(source_path)
        raise Morphosource::Derivatives::Obj2gltfError.new("Source file: #{source_path} does not exist.")
      end

      internal_call # to do add some output/post-process controls
    end

    protected 
        
    def command
      "obj2gltf -i '#{source_path}' -o '#{out_path}'"
    end

    # Check for produced derivative file, otherwise raise obj2gltf response as error
    def post_process(raw_output)
      if !File.exist?(out_path) || (File.size(out_path) == 0)
        raise Morphosource::Derivatives::Obj2gltfError.new("File not successfully created by derivative tool.\nTool command: \"#{command}\"\nTool output:\n\"#{raw_output}\"")
      end
    end
  end
end
