module Morphosource::Derivatives
  class FijiError < RuntimeError
  end

  class Fiji < DerivativeTool
    class_attribute :tool_path

    attr_reader :input_path, :output_path, :linear_scale_factor, :tool_path, :tmp_dir_path, :macro_path
    def initialize(input_path, output_path, linear_scale_factor, tool_path = nil)
      @input_path = input_path
      @output_path = output_path
      @linear_scale_factor = linear_scale_factor
      @tool_path = tool_path

      @tmp_dir_path = Rails.root.join('tmp', SecureRandom.uuid)
      Dir.mkdir tmp_dir_path unless File.exist? tmp_dir_path
    end

    def call
      unless Dir.exists?(input_path)
        raise Morphosource::Derivatives::FijiError.new("Input directory: #{input_path} does not exist.")
      end

      imagej_macro
      internal_call # to do add some output/post-process controls
      cleanup_tmp_files
    end

    def tool_path
      @tool_path || Morphosource::Derivatives.fiji_path
    end

    protected
      def imagej_macro
        erb_src = File.join(__dir__, 'imagej_macro.txt.erb')
        txt_dst = File.join(tmp_dir_path, File.basename(erb_src, '.erb'))
        File.open(txt_dst, 'w') do |f|
          f.write(ERB.new(File.read(erb_src)).result(binding))
        end
        @macro_path = txt_dst
      end

      def cleanup_tmp_files
        FileUtils.remove_dir tmp_dir_path
      end

      def command
        "#{tool_path}/Fiji.app/ImageJ-linux64 --headless -macro #{macro_path}"
      end
  end
end
