module Morphosource::Derivatives
  class BlenderError < RuntimeError
  end

  class Blender < DerivativeTool
    class_attribute :tool_path

    attr_reader :source_path, :out_path, :units
    def initialize(source_path, out_path, units = nil, tool_path = nil)
      @source_path = source_path
      @out_path = out_path
      @units = units.presence || 'm'
      @tool_path = tool_path
    end

    def call
      unless File.exists?(source_path)
        raise Morphosource::Derivatives::BlenderError.new("Source file: #{source_path} does not exist.")
      end

      internal_call # to do add some output/post-process controls
    end

    def tool_path
      @tool_path || Morphosource::Derivatives.blender_path
    end

    protected
      def command
        # "#{tool_path}/blender --background --factory-startup --addons io_scene_gltf2 --python #{tool_path}/scripts/blender_derive_mesh.py -- -i #{source_path} -o #{out_path} -u #{units}"
        "#{tool_path}/blender --background --factory-startup --addons io_scene_gltf2 --python vendor/blender_config/scripts/blender_derive_mesh.py -- -i #{source_path} -o #{out_path} -u #{units}"
      end
  end
end
