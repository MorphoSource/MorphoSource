module Morphosource::Derivatives
  class DcmcjpegError < RuntimeError
  end

  class Dcmcjpeg < DerivativeTool
    attr_reader :source_path, :out_path, :file_path, :file_out_path
    def initialize(source_path, out_path)
      @source_path = source_path
      @out_path = out_path
    end

    def call
      unless Dir.exist?(source_path)
        raise Morphosource::Derivatives::DcmcjpegError.new("Source directory: #{source_path} does not exist.")
      end

      internal_call
    end

    protected

    def internal_call
      Dir.foreach(source_path) do |f|
        next if File.extname(f).downcase != '.dcm' && File.extname(f).downcase != '.dicom'
          @file_path = File.join(source_path, f)
          @file_out_path = File.join(out_path, f)
          output = process_file
          post_process(output)
      end
    end

    def command
      "dcmcjpeg --encode-lossless-sv1 '#{file_path}' '#{file_out_path}'"
    end

    # Check for produced derivative file, otherwise raise Dcmcjpeg response as error
    def post_process(raw_output)
      if !File.exist?(file_out_path) || (File.size(file_out_path) == 0)
        raise Morphosource::Derivatives::DcmcjpegError.new("File not successfully created by derivative tool.\nTool command: \"#{command}\"\nTool output:\n\"#{raw_output}\"")
      end
    end
  end
end
