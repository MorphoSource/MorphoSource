module Hydra::Works::Characterization
  class MeshSchema < ActiveTriples::Schema
    property :point_count, predicate: RDF::URI('https://www.morphosource.org/terms/pointCount')
    property :face_count, predicate: RDF::URI('https://www.morphosource.org/terms/faceCount')
    property :edges_per_face, predicate: RDF::URI('https://www.morphosource.org/terms/edgesPerFace')
    property :bounding_box_x, predicate: RDF::URI('https://www.morphosource.org/terms/boundingBoxX')
    property :bounding_box_y, predicate: RDF::URI('https://www.morphosource.org/terms/boundingBoxY')
    property :bounding_box_z, predicate: RDF::URI('https://www.morphosource.org/terms/boundingBoxZ')
    property :color_format, predicate: RDF::URI('https://www.morphosource.org/terms/colorFormat')
    property :normals_format, predicate: RDF::URI('https://www.morphosource.org/terms/normalsFormat')
    property :has_uv_space, predicate: RDF::URI('https://www.morphosource.org/terms/hasUVSpace')
    property :vertex_color, predicate: RDF::URI('https://www.morphosource.org/terms/vertexColor')
    property :centroid_x, predicate: RDF::URI('https://www.morphosource.org/terms/centroidX')
    property :centroid_y, predicate: RDF::URI('https://www.morphosource.org/terms/centroidY')
    property :centroid_z, predicate: RDF::URI('https://www.morphosource.org/terms/centroidZ')
  end
end
