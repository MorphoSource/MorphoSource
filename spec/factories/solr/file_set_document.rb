# Factory for FileSet SolrDocument instances
FILE_SET_DOC_ATTRIBUTES = {
  id: "678912345",
  has_model_ssim: ["FileSet"],
  title_tesim: ["file.zip"],
  label_tesim: ["file.zip"],
  label_ssi: "file.zip",
  bits_allocated_tesim: ["16"], 
  bits_per_sample_tesim: ["32"], 
  bounding_box_x_tesim: ["0.1"], 
  bounding_box_y_tesim: ["0.1"], 
  bounding_box_z_tesim: ["0.1"], 
  centroid_x_tesim: ["0.5"], 
  centroid_y_tesim: ["0.5"], 
  centroid_z_tesim: ["0.5"], 
  columns_tesim: ["1200"], 
  contents_accepted_file_count_tesim: ["1600"], 
  color_format_tesim: ["vertex color"], 
  color_space_tesim: ["RGB"], 
  compression_tesim: ["JPEG"], 
  face_count_tesim: ["14000"],
  file_size_lts: 123456789,
  has_uv_space_tesim: ["True"], 
  height_is: 900, 
  normals_format_tesim: ["UV"], 
  original_file_id_ssi: ["1234-1234-1234"], 
  point_count_tesim: ["7000"], 
  rows_tesim: ["600"], 
  vertex_color_tesim: ["True"], 
  width_is: 1800
}

FactoryBot.define do
  factory :file_set_document, class: "SolrDocument" do
    initialize_with { new(FILE_SET_DOC_ATTRIBUTES) }
    to_create { |instance| ActiveFedora::SolrService.add(instance.to_h, softCommit: true)}
  end
end