# Derivative tool to convert PLY mesh files directly to GLB, preserving per-vertex color
module Morphosource::Derivatives
  class AssimpError < RuntimeError
  end

  class Assimp < DerivativeTool
    attr_reader :source_path, :out_path

    def initialize(source_path, out_path)
      @source_path = source_path
      @out_path = out_path
    end

    def call
      unless File.exist?(source_path)
        raise Morphosource::Derivatives::AssimpError.new("Source file: #{source_path} does not exist.")
      end

      internal_call
    end

    protected

    def command
      "assimp export '#{source_path}' '#{out_path}'"
    end

    # Check for produced derivative file, otherwise raise Assimp response as error
    def post_process(raw_output)
      if !File.exist?(out_path) || (File.size(out_path) == 0)
        raise Morphosource::Derivatives::AssimpError.new("File not successfully created by derivative tool.\nTool command: \"#{command}\"\nTool output:\n\"#{raw_output}\"")
      end
    end
  end
end
