module Morphosource::Derivatives
  class Extract7ZipError < RuntimeError
  end

  # Very simple tool to extract files from an archive using 7Zip, usually to salvage a DEFLATE64 archive
  class Extract7Zip < DerivativeTool
    attr_reader :file, :dir_path

    def initialize(file, dir_path)
      @file = file
      @dir_path = dir_path
    end

    def call
      unless File.exists?(file)
        raise Morphosource::Derivatives::Extract7ZipError.new("Source file: #{file} does not exist")
      end

      internal_call
    end

    protected

    def command
      "7zz x -o\"#{dir_path}\" -y #{file}"
    end

    def post_process(raw_output)
      if Dir[File.join(dir_path, "**", "*")].count == 0
        raise Morphosource::Derivatives::Extract7ZipError.new("Files not successfully extracted by 7Zip.\nTool command: \"#{command}\"\nTool output:\n\"#{raw_output}\"")
      end
    end
  end
end