require 'hydra/file_characterization/exceptions'
require 'hydra/file_characterization/characterizer'
require 'logger'
module Hydra::FileCharacterization::Characterizers
  class Blender < Hydra::FileCharacterization::Characterizer

    protected

      def command
        "#{tool_path}/blender --background --factory-startup --addons io_scene_gltf2 --python vendor/blender_config/scripts/blender_characterize_mesh.py -- #{filename}"
      end
  
      # Remove any non-XML output that precedes the <?xml> tag
      # todo: possibly remove blender errors and non-xml output
      def post_process(raw_output)
        md = /\A(.*)(<\?xml.*)\Z/m.match(raw_output)
        logger.warn "----- WARNING ----- Blender produced non-xml output: \"#{md[1].chomp}\"" unless md[1].empty?
        md[2]
      end
  end
end
