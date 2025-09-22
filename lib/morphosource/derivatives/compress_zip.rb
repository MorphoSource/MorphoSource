module Morphosource::Derivatives
  class CompressZipError < RuntimeError
  end

  # Very simple tool to compress directory of files into a ZIP
  class CompressZip < DerivativeTool
    attr_reader :dir_path, :file

    def initialize(dir_path, file) 
      @dir_path = dir_path
      @file = file
    end

    def call
      unless File.exist?(dir_path)
        raise Morphosource::Derivatives::CompressZipError.new("Source directory: #{dir_path} does not exist")
      end

      internal_call
    end

    protected

    def command
      "cd #{dir_path} && zip -r #{file} ./*"
    end

    def post_process(raw_output)
      if !File.exist?(file) || (File.size(file) == 0)
        raise Morphosource::Derivatives::CompressZipError.new("ZIP file not successfully created.\nTool command: \"#{command}\"\nTool output:\n\"#{raw_output}\"")
      end
    end
  end
end