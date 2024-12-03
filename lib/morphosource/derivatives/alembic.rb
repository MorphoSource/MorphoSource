module Morphosource::Derivatives
  class AlembicError < RuntimeError
  end

  class Alembic < DerivativeTool
    class_attribute :tool_path

    attr_reader :source_path, :out_path, :x, :y, :z, :thickness, :file_path, :file_out_path
    def initialize(source_path, out_path, x=nil, y=nil, z=nil, thickness=nil, tool_path=nil)
      @source_path = source_path
      @out_path = out_path
      @x = x
      @y = y
      @z = z
      @thickness = thickness
      @tool_path = tool_path
    end

    def call
      unless Dir.exist?(source_path)
        raise Morphosource::Derivatives::AlembicError.new("Source directory: #{source_path} does not exist.")
      end

      internal_call
    end

    def tool_path
      @tool_path || Morphosource::Derivatives.python_path
    end

    protected
    
    def command
      cmd = "#{tool_path} vendor/alembic/transmute.py -- -i '#{source_path}' -o '#{out_path}' " +
        ( x ? "-x #{x} " : "") +
        ( y ? "-y #{y} " : "") +
        ( z ? "-s #{z} " : "") +
        ( thickness ? "-t #{thickness} " : "")
      puts(cmd)
      cmd
    end

    # Check for produced derivative file, otherwise raise Alembic response as error
    def post_process(raw_output)
      if !File.exist?(out_path) || (File.size(out_path) == 0)
        raise Morphosource::Derivatives::AlembicError.new("File not successfully created by derivative tool.\nTool command: \"#{command}\"\nTool output:\n\"#{raw_output}\"")
      end
    end
  end
end
