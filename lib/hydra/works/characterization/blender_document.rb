require 'om'

module Hydra::Works::Characterization
  class BlenderDocument
    include OM::XML::Document
    set_terminology do |t|
      t.root(path: 'blender')
      t.identification do
        t.identity do
          t.format_label(path: { attribute: 'format' })
          t.mime_type(path: { attribute: 'mimetype' })
        end
      end
      t.fileinfo do
        t.file_size(path: 'size')
        t.filename(path: 'filename')
        t.original_checksum(path: 'md5checksum')
        t.rights_basis(path: 'rightsBasis')
        t.copyright_basis(path: 'copyrightBasis')
        t.copyright_note(path: 'copyrightNote')
      end
      t.filestatus do
        t.well_formed(path: 'well-formed')
        t.valid(path: 'valid')
        t.status_message(path: 'message')
      end
      t.metadata do
        t.mesh do
          t.point_count(path: 'pointCount')
          t.face_count(path: 'faceCount')
          t.boundingboxdimensions do
            t.bounding_box_x(path: 'boundingBoxX')
            t.bounding_box_y(path: 'boundingBoxY')
            t.bounding_box_z(path: 'boundingBoxZ')
          end
          t.centroid do
            t.centroid_x(path: 'centroidX')
            t.centroid_y(path: 'centroidY')
            t.centroid_z(path: 'centroidZ')
          end
          t.edges_per_face(path: 'edgesPerFace')
          t.color_format(path: 'colorFormat')
          t.normals_format(path: 'normalsFormat')
          t.has_uv_space(path: 'hasUvSpace')
          t.vertex_color(path: 'vertexColor')
        end
      end
      # fits_version needs a different name than it's target node since they're at the same level
      #t.fits_version(proxy: [:fits, :fits_v])
      t.format_label(proxy: [:identification, :identity, :format_label])
      # Can't use .mime_type because it's already defined for this dcoument so method missing won't work.
      t.file_mime_type(proxy: [:identification, :identity, :mime_type])
      t.file_size(proxy: [:fileinfo, :file_size])
      t.filename(proxy: [:fileinfo, :filename])
      t.original_checksum(proxy: [:fileinfo, :original_checksum])
      t.rights_basis(proxy: [:fileinfo, :rights_basis])
      t.copyright_basis(proxy: [:fileinfo, :copyright_basis])
      t.copyright_note(proxy: [:fileinfo, :copyright_note])
      t.well_formed(proxy: [:filestatus, :well_formed])
      t.valid(proxy: [:filestatus, :valid])
      t.filestatus_message(proxy: [:filestatus, :status_message])

      # mesh specific attributes 
      t.point_count(proxy: [:metadata, :mesh, :point_count])
      t.face_count(proxy: [:metadata, :mesh, :face_count])
      t.bounding_box_x(proxy: [:metadata, :mesh, :boundingboxdimensions, :bounding_box_x])
      t.bounding_box_y(proxy: [:metadata, :mesh, :boundingboxdimensions, :bounding_box_y])
      t.bounding_box_z(proxy: [:metadata, :mesh, :boundingboxdimensions, :bounding_box_z])
      t.centroid_x(proxy: [:metadata, :mesh, :centroid, :centroid_x])
      t.centroid_y(proxy: [:metadata, :mesh, :centroid, :centroid_y])
      t.centroid_z(proxy: [:metadata, :mesh, :centroid, :centroid_z])
      t.edges_per_face(proxy: [:metadata, :mesh, :edges_per_face])
      t.color_format(proxy: [:metadata, :mesh, :color_format])
      t.normals_format(proxy: [:metadata, :mesh, :normals_format])
      t.has_uv_space(proxy: [:metadata, :mesh, :has_uv_space])
      t.vertex_color(proxy: [:metadata, :mesh, :vertex_color])
    end

    # Cleanup phase; ugly name to avoid collisions.
    # The send construct here is required to fix up values because the setters
    # are not defined, but rather applied with method_missing.
    def __cleanup__
      # Sometimes, FITS reports the mimetype attribute as a comma-separated string.
      # All terms are arrays and, in this case, there is only one element, so scan the first.
      if file_mime_type.present? && file_mime_type.first.include?(',')
        send("file_mime_type=", [file_mime_type.first.split(',').first])
      end

      # Add any other scrubbers here; don't return any particular value
      nil
    end

#    def self.xml_template
#      builder = Nokogiri::XML::Builder.new do |xml|
#        xml.fits(xmlns: 'http://hul.harvard.edu/ois/xml/ns/fits/fits_output',
#                 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
#                 'xsi:schemaLocation' => "http://hul.harvard.edu/ois/xml/ns/fits/fits_output
#                 http://hul.harvard.edu/ois/xml/xsd/fits/fits_output.xsd",
#                 version: '0.6.0', timestamp: '1/25/12 11:04 AM') do
#          xml.identification { xml.identity(toolname: 'FITS') }
#        end
#      end
#      builder.doc
#    end
  end
end