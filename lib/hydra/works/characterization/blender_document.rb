module Hydra::Works::Characterization
  class BlenderDocument
    attr_accessor :ng_xml

    PROXIED_TERMS = %i(
      format_label  file_mime_type blender_version gltf_inspect_version

      file_size filename original_checksum rights_basis copyright_basis copyright_note
      well_formed valid filestatus_message

      point_count face_count bounding_box_x bounding_box_y bounding_box_z
      centroid_x centroid_y centroid_z centroid_method edges_per_face color_format normals_format 
      has_uv_space vertex_color
    ).freeze

    def proxied_term_hash
      PROXIED_TERMS.map { |t| [t, send(t)] }.to_h
    end

    def self.terminology
      struct = Struct.new(:proxied_term).new
      terminology = Struct.new(:terms)
      terminology.new(PROXIED_TERMS.map { |t| [t, struct] }.to_h)
    end

    # t.format_label(proxy: [:identification, :identity, :format_label])
    def format_label
      ng_xml.css("blender > identification > identity").map { |n| n['format'] }
    end

    # Can't use .mime_type because it's already defined for this document so method missing won't work.
    # t.file_mime_type(proxy: [:identification, :identity, :mime_type])
    def file_mime_type
      # Sometimes, FITS reports the mimetype attribute as a comma-separated string.
      # All terms are arrays and, in this case, there is only one element, so scan the first.
      ng_xml.css("blender > identification > identity").map { |n| n['mimetype'].split(',').first }
    end

    # t.blender_version(proxy: [:identification, :identity, :tool, :blender_version])
    def blender_version
      ng_xml.css("blender > identification > identity > tool").first.at("blenderVersion").text
    end

    # t.gltf_inspect_version(proxy: [:identification, :identity, :tool, :gltf_inspect_version])
    def gltf_inspect_version
      ng_xml.css("blender > identification > identity > tool").first.at("gltfInspectVersion").text
    end

    # @!group file

    # t.file_size(proxy: [:fileinfo, :file_size])
    def file_size
      ng_xml.css("blender > fileinfo > size").map(&:text)
    end

    #  t.filename(proxy: [:fileinfo, :filename])
    def filename
      ng_xml.css("blender > fileinfo > filename").map(&:text)
    end

    # t.original_checksum(proxy: [:fileinfo, :original_checksum])
    def original_checksum
      ng_xml.css("blender > fileinfo > md5checksum").map(&:text)
    end

    # t.rights_basis(proxy: [:fileinfo, :rights_basis])
    def rights_basis
      ng_xml.css("blender > fileinfo > rightsBasis").map(&:text)
    end

    # t.copyright_basis(proxy: [:fileinfo, :copyright_basis])
    def copyright_basis
      ng_xml.css("blender > fileinfo > copyrightBasis").map(&:text)
    end

    # t.copyright_basis(proxy: [:fileinfo, :copyright_note])
    def copyright_note
      ng_xml.css("blender > fileinfo > copyrightNote").map(&:text)
    end

    # t.well_formed(proxy: [:filestatus, :well_formed])
    def well_formed
      ng_xml.css("blender > filestatus > well-formed").map(&:text)
    end

    # t.valid(proxy: [:filestatus, :valid])
    def valid
      ng_xml.css("blender > filestatus > valid").map(&:text)
    end

    # t.filestatus_message(proxy: [:filestatus, :status_message])
    def filestatus_message
      ng_xml.css("blender > filestatus > message").map(&:text)
    end

    # @!endgroup
    # @!group mesh

    # t.point_count(proxy: [:metadata, :mesh, :point_count])
    def point_count
      ng_xml.css("blender > metadata > mesh > pointCount").map(&:text)
    end

    # t.face_count(proxy: [:metadata, :mesh, :face_count])
    def face_count
      ng_xml.css("blender > metadata > mesh > faceCount").map(&:text)
    end

    # t.bounding_box_x(proxy: [:metadata, :mesh, :boundingboxdimensions, :bounding_box_x])
    def bounding_box_x
      ng_xml.css("blender > metadata > mesh > boundingboxdimensions > boundingBoxX").map(&:text)
    end

    # t.bounding_box_y(proxy: [:metadata, :mesh, :boundingboxdimensions, :bounding_box_y])
    def bounding_box_y
      ng_xml.css("blender > metadata > mesh > boundingboxdimensions > boundingBoxY").map(&:text)
    end

    # t.bounding_box_z(proxy: [:metadata, :mesh, :boundingboxdimensions, :bounding_box_z])
    def bounding_box_z
      ng_xml.css("blender > metadata > mesh > boundingboxdimensions > boundingBoxZ").map(&:text)
    end

    # t.centroid_x(proxy: [:metadata, :mesh, :centroid, :centroid_x])
    def centroid_x
      ng_xml.css("blender > metadata > mesh > centroid > centroidX").map(&:text)
    end

    # t.centroid_y(proxy: [:metadata, :mesh, :centroid, :centroid_y])
    def centroid_y
      ng_xml.css("blender > metadata > mesh > centroid > centroidY").map(&:text)
    end

    # t.centroid_z(proxy: [:metadata, :mesh, :centroid, :centroid_z])
    def centroid_z
      ng_xml.css("blender > metadata > mesh > centroid > centroidZ").map(&:text)
    end

    # t.centroid_method(proxy: [:metadata, :mesh, :centroid, :centroid_method])
    def centroid_method
      ng_xml.css("blender > metadata > mesh > centroid > centroidMethod").map(&:text)
    end

    # t.edges_per_face(proxy: [:metadata, :mesh, :edges_per_face])
    def edges_per_face
      ng_xml.css("blender > metadata > mesh > edgesPerFace").map(&:text)
    end

    # t.color_format(proxy: [:metadata, :mesh, :color_format])
    def color_format
      ng_xml.css("blender > metadata > mesh > colorFormat").map(&:text)
    end

    # t.normals_format(proxy: [:metadata, :mesh, :normals_format])
    def normals_format
      ng_xml.css("blender > metadata > mesh > normalsFormat").map(&:text)
    end

    # t.has_uv_space(proxy: [:metadata, :mesh, :has_uv_space])
    def has_uv_space
      ng_xml.css("blender > metadata > mesh > hasUvSpace").map(&:text)
    end

    # t.vertex_color(proxy: [:metadata, :mesh, :vertex_color])
    def vertex_color
      ng_xml.css("blender > metadata > mesh > vertexColor").map(&:text)
    end

    # @!endgroup

    # Cleanup phase; ugly name to avoid collisions.
    # The send construct here is required to fix up values because the setters
    # are not defined, but rather applied with method_missing.
    def __cleanup__
      # Add any other scrubbers here; don't return any particular value
      nil
    end
  end
end