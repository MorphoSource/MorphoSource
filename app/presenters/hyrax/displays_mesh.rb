require 'iiif_manifest'

module Hyrax
  # This gets mixed into MediaFileSetPresenter in order to create
  # a canvas on a IIIF manifest
  module DisplaysMesh
    extend ActiveSupport::Concern

    # (TODO) Creates a display mesh3d only where FileSet is a mesh3d.
    #
    # @return [IIIFManifest::DisplayMesh3D] display mesh3d usable by the manifest builder.
    def display_mesh
      return nil unless ::FileSet.exists?(id) && solr_document.mesh? && current_ability.can?(:read, id)
      # @todo this is slow, find a better way (perhaps index iiif url):
      # original_file = ::FileSet.find(id).original_file

      # Need to find a different way to point to the public mesh file URL, or can I use the old one? Should test in console?
      # url = URI::join(request.base_url, '/downloads/', id).to_s;
      url = Hyrax::Engine.routes.url_helpers.download_path(id, file: 'glb')
      # url = Hyrax.config.iiif_image_url_builder.call(
      #   original_file.id,
      #   request.base_url,
      #   Hyrax.config.iiif_image_size_default
      # )

      format = 'model/gltf+json'
      type = 'PhysicalObject'

      # @see https://github.com/samvera-labs/iiif_manifest TODO: Change this to eventual mesh3D fork?
      IIIFManifest::DisplayMesh.new(url, 
                                    format: format, 
                                    type: type)
    end

    private

      # def iiif_endpoint(file_id) # TODO: This endpoint returns an "error: no info" in the JSON object
      #   return unless Hyrax.config.iiif_image_server?
      #   IIIFManifest::IIIFEndpoint.new(
      #     Hyrax.config.iiif_info_url_builder.call(file_id, request.base_url),
      #     profile: Hyrax.config.iiif_image_compliance_level_uri
      #   )
      # end
  end
end