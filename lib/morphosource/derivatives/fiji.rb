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
      unless Dir.exist?(input_path)
        raise Morphosource::Derivatives::FijiError.new("Input directory: #{input_path} does not exist.")
      end

      internal_call # to do add some output/post-process controls
    end

    def tool_path
      @tool_path || Morphosource::Derivatives.fiji_path
    end

    def custom_fiji_executable_path
      @custom_fiji_executable_path || Morphosource::Derivatives.fiji_script_command
    end

    protected

    def script_path
      File.join(__dir__, 'imagej_script.js')
    end

    def script_parameters
      "input_path=\"#{dir_wrap(input_path)}\",output_path=\"#{dir_wrap(output_path)}\",linear_scale_factor=#{linear_scale_factor}"
    end

    def dir_wrap(d)
      # ensure dir path ends with trailing '/'
      File.join(d, '')
    end

    def command_path
      if custom_fiji_executable_path.present?
        custom_fiji_executable_path
      else
        "#{tool_path}/Fiji.app/ImageJ-linux64 --ij2 --headless --console --run"
      end
    end

    def command
      "#{command_path} #{script_path} '#{script_parameters}'"
    end

    # Check for produced derivative files, otherwise raise Fiji response as error
    def post_process(raw_output)
      if Dir[File.join(output_path, '**', '*')].count { |file| File.file?(file) } == 0
        raise Morphosource::Derivatives::FijiError.new("File not successfully created by derivative tool.\nTool command: \"#{command}\"\nTool output:\n\"#{raw_output}\"")
      end
    end
  end
end
