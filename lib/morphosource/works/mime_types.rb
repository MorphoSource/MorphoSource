module Morphosource
  module Works
    module MimeTypes
      extend ActiveSupport::Concern
      include Hydra::Works::MimeTypes

      def mesh?
        self.class.mesh_mime_types.include?(mime_type) || self.class.archive_mime_types.include?(mime_type)
      end

      def volume?
        self.class.volume_mime_types.include? mime_type
      end

      module ClassMethods
        def mesh_mime_types
          ['application/ply', 'application/stl', 'text/prs.wavefront-obj', 'model/gltf+json', 'model/vrml', 'model/x3d+xml']
        end

        def archive_mime_types
          ['application/zip']
        end

        def volume_mime_types
          ['application/zip']
        end
      end
    end
  end
end
