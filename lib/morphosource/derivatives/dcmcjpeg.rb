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
      unless Dir.exists?(source_path)
        raise Morphosource::Derivatives::DcmcjpegError.new("Source directory: #{source_path} does not exist.")
      end

      internal_call # to do add some output/post-process controls
    end

    protected
      def internal_call
        Dir.foreach(source_path) do |f|
          next if File.extname(f).downcase != '.dcm' && File.extname(f).downcase != '.dicom'
            @file_path = File.join(source_path, f)
            @file_out_path = File.join(out_path, f)
            process_file
        end
      end

      def command
        "dcmcjpeg --encode-lossless-sv1 '#{file_path}' '#{file_out_path}'"
      end
  end
end
