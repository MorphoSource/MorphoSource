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
      unless File.exist?(file_path)
        raise Morphosource::Derivatives::Dcmj2pnmError.new("Source file: #{file_path} does not exist.")
      end

      internal_call # to do add some output/post-process controls
    end

    protected

    def command
      "dcmj2pnm '#{file_path}' '#{file_out_path}' --write-16-bit-png"
    end

    # Check for produced derivative file, otherwise raise Dcmj2pnm response as error
    def post_process(raw_output)
      if !File.exist?(file_out_path) || (File.size(file_out_path) == 0)
        raise Morphosource::Derivatives::Dcmj2pnmError.new("File not successfully created by derivative tool.\nTool command: \"#{command}\"\nTool output:\n\"#{raw_output}\"")
      end
    end
  end
end
