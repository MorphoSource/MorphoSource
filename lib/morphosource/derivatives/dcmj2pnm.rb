module Morphosource::Derivatives
  class Dcmj2pnmError < RuntimeError
  end

  class Dcmj2pnm < DerivativeTool
    attr_reader :file_path, :file_out_path
    def initialize(file_path, file_out_path)
      @file_path = file_path
      @file_out_path = file_out_path
    end

    def call
      unless File.exists?(file_path)
        raise Morphosource::Derivatives::Dcmj2pnmError.new("Source file: #{file_path} does not exist.")
      end

      internal_call # to do add some output/post-process controls
    end

    protected
      def internal_call
        process_file
      end

      def command
        "dcmj2pnm '#{file_path}' '#{file_out_path}' --write-16-bit-png"
      end
  end
end
