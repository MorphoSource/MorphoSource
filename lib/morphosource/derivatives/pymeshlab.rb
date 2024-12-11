# Derivative tool to convert mesh files to OBJ format
module Morphosource::Derivatives
  class PymeshlabError < RuntimeError
  end

  class Pymeshlab < DerivativeTool
    class_attribute :tool_path

    attr_reader :source_path, :out_path

    def initialize(source_path, out_path, tool_path = nil)
      @source_path = source_path
      @out_path = out_path
      @tool_path = tool_path
    end

    def call
      unless File.exist?(source_path)
        raise Morphosource::Derivatives::PymeshlabError.new("Source file: #{source_path} does not exist.")
      end

      internal_call
    end

    def tool_path
      @tool_path || Morphosource::Derivatives.python_path
    end

    protected

    def command
      "#{tool_path} vendor/pymeshlab/pymeshlab_convert_mesh.py -- -i '#{source_path}' -o '#{out_path}'"
    end

    # Check for produced derivative file, otherwise raise Pymeshlab response as error
    def post_process(raw_output)
      if !File.exist?(out_path) || (File.size(out_path) == 0)
        raise Morphosource::Derivatives::PymeshlabError.new("File not successfully created by derivative tool.\nTool command: \"#{command}\"\nTool output:\n\"#{raw_output}\"")
      end
    end
  end
end