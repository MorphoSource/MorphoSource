require 'hydra/file_characterization/exceptions'
require 'hydra/file_characterization/characterizer'
require 'logger'
module Hydra::FileCharacterization::Characterizers
  class Pymeshlab < Hydra::FileCharacterization::Characterizer

    protected

      def command_path
        Morphosource::Derivatives.python_path
      end

      def command
        "#{command_path} vendor/pymeshlab/pymeshlab_characterize_mesh.py -- -i '#{filename}'"
      end
  
      # Remove any non-XML output that precedes the <?xml> tag
      def post_process(raw_output)
        md = /\A(.*)(<\?xml.*)\Z/m.match(raw_output)
        logger.warn "----- WARNING ----- Pymeshlab produced non-xml output: \"#{md[1].chomp}\"" unless md[1].empty?
        md[2]
      end
  end
end
