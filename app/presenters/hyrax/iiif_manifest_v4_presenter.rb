# frozen_string_literal: true

module Hyrax
  ##
  # This presenter wraps objects in the interface required by `IIIFManifest`.
  # It will accept either a Work-like resource or a SolrDocument.
  # It is very similar to the IIIF Prezi V3 Hyrax::IiifManifestPresenter.
  #
  # @example with a work
  #
  #   monograph = Monograph.new
  #   presenter = IiifManifestPresenter.new(monograph)
  #   presenter.title # => []
  #
  #   monograph.title = ['Comet in Moominland']
  #   presenter.title # => ['Comet in Moominland']
  #
  # @see https://www.rubydoc.info/gems/iiif_manifest
  class IiifManifestV4Presenter < Hyrax::IiifManifestPresenter
    class << self
      ##
      # @param [Hyrax::Resource, SolrDocument]
      def for(model)
        klass = model.file_set? ? DisplayImagePresenter : IiifManifestPresenter

        klass.new(model)
      end
    end

    class DisplayImagePresenter < Hyrax::IiifManifestPresenter::DisplayImagePresenter
      ##
      # Displays scene commenting annotations as list of prezi-like hashes if present
      #
      # @return [Array<Hash>, nil] List of comment annotations or nil if not present 
      def display_comments
        return nil unless model.mesh? || model.volume?
        return nil unless latest_file_id

        scene&.iiif_annotations
      end

      ##
      # Displays scene camera annotations (activated by commenting annotations via scope) if present
      #
      # @return [Array<Hash>, nil] List of camera annotations or nil if not present
      def display_cameras
        return nil unless model.mesh? || model.volume?
        return nil unless latest_file_id

        scene&.iiif_cameras
      end

      ##
      # Creates a display mesh only where #model is a mesh.
      #
      # @return [IIIFManifest::V4::DisplayContent] the display mesh required by the manifest builder.
      def display_content_mesh
        return nil unless model.mesh?
        return nil unless latest_file_id
        display_scene_content('glb', 'model/gltf+json', 'Model')
      end

      ##
      # Creates a display volume only where #model is a volume.
      #
      # @return [IIIFManifest::V4::DisplayContent] usable by the manifest builder.
      def display_content_volume
        return nil unless model.volume?
        return nil unless latest_file_id
        display_scene_content('dcm', 'application/dicom', 'Model')
      end

      ##
      # Creates a generic singular content display downloadable through #model access control id
      #
      # @return [IIIFManifest::V4::DisplayContent] the display content required by the manifest builder.
      def display_generic_download_content(download_file_suffix, format, type)
        IIIFManifest::V4::DisplayContent.new(
          URI::join(
            hostname,
            Rails.application.routes.url_helpers.download_path(model.access_control_id, file: download_file_suffix)
          ),
          format: format,
          type: type
        )
      end

      ##
      # Creates a content display to be painted in 3D scene with transforms and commenting annotations
      #
      # @return [IIIFManifest::V4::DisplayContent] the display content required by the manifest builder.
      def display_scene_content(download_file_suffix, format, type)
        IIIFManifest::V4::DisplayContent.new(URI::join(
            hostname,
            Rails.application.routes.url_helpers.download_path(model.access_control_id, file: download_file_suffix)
          ),
          format: format,
          type: type,
          transform: scene&.iiif_transforms
        )
      end

      private

        def scene
          @scene ||= parent_work.present? ? Scene.find_by(media_id: parent_work.id) : nil
        end
    end
  end
end