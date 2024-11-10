module Morphosource
  module Works
    module MimeTypes
      extend ActiveSupport::Concern
      include Hydra::Works::MimeTypes

      def archive?
        self.class.archive_mime_types.include? mime_type
      end

      def mesh?
        self.class.mesh_mime_types.include?(mime_type) || self.class.archive_mime_types.include?(mime_type)
      end

      def volume?
        self.class.volume_mime_types.include? mime_type
      end

      module ClassMethods
        def mesh_mime_types
          @mesh_mime_types ||= gltf_mesh_mime_types + obj_mesh_mime_types + misc_mesh_mime_types
        end

        def gltf_mesh_mime_types
          ['model/gltf+json']
        end

        def obj_mesh_mime_types
          ['text/prs.wavefront-obj']
        end

        def misc_mesh_mime_types
          ['application/ply', 'application/stl', 'model/vrml', 'model/x3d+xml']
        end

        def archive_mime_types
          ['application/zip', 'application/x-tar']
        end

        def volume_mime_types
          ['application/zip', 'application/x-tar']
        end
      end
    end
  end
end
