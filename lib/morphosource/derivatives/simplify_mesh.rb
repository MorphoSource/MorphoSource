module Morphosource::Derivatives
  class SimplifyMeshError < RuntimeError
  end

  class SimplifyMesh < DerivativeTool
    class_attribute :tool_path

    attr_reader :source_path, :out_path, :face_number
    def initialize(source_path, out_path, face_number = 1000000)
      @source_path = source_path
      @out_path = out_path
      @face_number = face_number
      @tool_path = tool_path
    end

    def call
      unless File.exists?(source_path)
        raise Morphosource::Derivatives::SimplifyMeshError.new("Source file: #{source_path} does not exist.")
      end

      internal_call # to do add some output/post-process controls
    end

    protected
      def internal_call
        process_file
        check_output
      end

      def check_output
        unless File.exists?(out_path)
          raise Morphosource::Derivatives::SimplifyMeshError.new("Simplify mesh output file: #{source_path} does not exist.")
        end
      end

      def command
        "python3 vendor/pymeshlab/simplify_mesh.py -- -i '#{source_path}' -o '#{out_path}' -n '#{face_number}'"
      end
  end
end
