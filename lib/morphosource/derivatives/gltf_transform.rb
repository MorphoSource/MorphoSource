module Morphosource::Derivatives
  class GltfTransformError < RuntimeError
  end

  # Derivative tool to interface with gltf-transform CLI utility
  class GltfTransform < DerivativeTool
    attr_reader :cli_command, :source_path, :out_path, :opts
    def initialize(cli_command:, source_path:, out_path:, opts: {})
      if accepted_cli_commands.include? cli_command
        @cli_command = cli_command
      else
        raise Morphosource::Derivatives::GltfTransformError.new("Unrecognized gltf-transform CLI command: #{cli_command}")
      end

      @source_path = source_path
      @out_path = out_path
      @opts = default_opts.merge(opts)
    end

    def accepted_cli_commands
      [:optimize, :center, :metalrough]
    end

    def default_opts
      opts_by_command[cli_command]
    end

    def opts_by_command
      {
        optimize: { max_texture_size: 1024, simplify: false, simplify_error: 0.0001 },
        center: { pivot: 'below' },
        metalrough: {}
      }
    end

    def call
      unless File.exist?(source_path)
        raise Morphosource::Derivatives::GltfTransformError.new("Source file: #{source_path} does not exist.")
      end

      internal_call
    end

    protected  

    def command
      case cli_command
      when :optimize
        "gltf-transform optimize '#{source_path}' '#{out_path}' \\
          --compress draco \\
          --simplify #{opts[:simplify]} \\
          --simplify-error #{opts[:simplify_error]} \\
          --texture-size #{opts[:max_texture_size]}"
      when :center
        "gltf-transform center '#{source_path}' '#{out_path}' \\
          --pivot #{opts[:pivot]}"
      when :metalrough
        "gltf-transform metalrough '#{source_path}' '#{out_path}'"
      end
    end

    # Check for produced derivative file, otherwise raise gltf-transform response as error
    def post_process(raw_output)
      if !File.exist?(out_path) || (File.size(out_path) == 0)
        raise Morphosource::Derivatives::GltfTransformError.new("File not successfully created by derivative tool.\nTool command: \"#{command}\"\nTool output:\n\"#{raw_output}\"")
      end
    end
  end
end