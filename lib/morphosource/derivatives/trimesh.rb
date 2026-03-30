# Derivative tool to convert PLY mesh files to GLB using trimesh,
# with correct sRGB->linear vertex color handling.
module Morphosource::Derivatives
  class TrimeshError < RuntimeError
  end

  class Trimesh < DerivativeTool
    class_attribute :tool_path

    attr_reader :source_path, :out_path

    def initialize(source_path, out_path, tool_path = nil)
      @source_path = source_path
      @out_path = out_path
      @tool_path = tool_path
    end

    def call
      unless File.exist?(source_path)
        raise Morphosource::Derivatives::TrimeshError.new("Source file: #{source_path} does not exist.")
      end

      internal_call
    end

    def tool_path
      @tool_path || Morphosource::Derivatives.python_path
    end

    protected

    def command
      "#{tool_path} vendor/trimesh/ply_to_glb.py -- -i '#{source_path}' -o '#{out_path}'"
    end

    # Check for produced derivative file, otherwise raise Trimesh response as error
    def post_process(raw_output)
      if !File.exist?(out_path) || (File.size(out_path) == 0)
        raise Morphosource::Derivatives::TrimeshError.new("File not successfully created by derivative tool.\nTool command: \"#{command}\"\nTool output:\n\"#{raw_output}\"")
      end
    end
  end
end
