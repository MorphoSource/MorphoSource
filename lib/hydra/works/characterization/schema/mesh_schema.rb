module Hydra::Works::Characterization
  class MeshSchema < ActiveTriples::Schema
    property :point_count, predicate: RDF::URI('https://www.morphosource.org/terms/pointCount'), replace_prev_val: true
    property :face_count, predicate: RDF::URI('https://www.morphosource.org/terms/faceCount'), replace_prev_val: true
    property :edges_per_face, predicate: RDF::URI('https://www.morphosource.org/terms/edgesPerFace')
    property :bounding_box_x, predicate: RDF::URI('https://www.morphosource.org/terms/boundingBoxX'), replace_prev_val: true
    property :bounding_box_y, predicate: RDF::URI('https://www.morphosource.org/terms/boundingBoxY'), replace_prev_val: true
    property :bounding_box_z, predicate: RDF::URI('https://www.morphosource.org/terms/boundingBoxZ'), replace_prev_val: true
    property :color_format, predicate: RDF::URI('https://www.morphosource.org/terms/colorFormat')
    property :normals_format, predicate: RDF::URI('https://www.morphosource.org/terms/normalsFormat')
    property :has_uv_space, predicate: RDF::URI('https://www.morphosource.org/terms/hasUVSpace'), replace_prev_val: true
    property :vertex_color, predicate: RDF::URI('https://www.morphosource.org/terms/vertexColor'), replace_prev_val: true
    property :centroid_x, predicate: RDF::URI('https://www.morphosource.org/terms/centroidX'), replace_prev_val: true
    property :centroid_y, predicate: RDF::URI('https://www.morphosource.org/terms/centroidY'), replace_prev_val: true
    property :centroid_z, predicate: RDF::URI('https://www.morphosource.org/terms/centroidZ'), replace_prev_val: true
    property :centroid_method, predicate: RDF::URI('https://www.morphosource.org/terms/centroidMethod'), replace_prev_val: true
    property :blender_version, predicate: RDF::URI('https://www.morphosource.org/terms/blenderVersion')
    property :gltf_inspect_version, predicate: RDF::URI('https://www.morphosource.org/terms/gltfInspectVersion')
    property :pymeshlab_version, predicate: RDF::URI('https://www.morphosource.org/terms/pymeshlabVersion')
  end
end
