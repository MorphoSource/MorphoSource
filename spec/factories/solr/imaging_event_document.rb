# Factory for Imaging Event SolrDocument instances
IMAGING_EVENT_DOC_ATTRIBUTES = {
  has_model_ssim: ["ImagingEvent"],
  creator_tesim: ["Creator"],
  date_created_tesim: ["01/01/2001"],
  device_id_tesim: ["567891234"],
  software_tesim: ["Software"],
  description_tesim: ["Description"],
  acquisition_type_tesim: ["Stationary"],
  amperage_tesim: ["10.0"],
  background_removal_tesim: ["Yes"],
  detector_configuration_tesim: ["Area (single or tiled detector)"],
  detector_pixels_x_tesim: ["10"],
  detector_pixels_y_tesim: ["10"],
  detector_pixel_size_x_tesim: ["0.1"],
  detector_pixel_size_y_tesim: ["0.1"],
  detector_type_tesim: ["Direct (X-Ray photoconductor)"],
  exposure_time_tesim: ["60.0"],
  flux_normalization_tesim: ["No"],
  focal_length_type_tesim: ["Fixed"],
  frame_averaging_tesim: ["3"],
  ie_filter_tesim: ["Tungsten"],
  ie_modality_tesim: ["MicroNanoXRayComputedTomography"],
  lens_make_tesim: ["Canon"],
  lens_model_tesim: ["X10"],
  light_source_tesim: ["Sun"],
  member_ids_ssim: nil,
  optical_magnification_tesim: ["Yes"],
  phase_contrast_tesim: ["No"],
  pixel_spacing_calibration_tesim: ["Yes"],
  power_tesim: ["120"],
  projections_tesim: ["1100"],
  rotation_number_tesim: ["12"],
  shading_correction_tesim: ["Yes"],
  slide_type_tesim: ["Histological"],
  source_detector_distance_tesim: ["5.0"],
  source_object_distance_tesim: ["5.0"],
  surrounding_material_tesim: ["Wedge"],
  voltage_tesim: ["240"],
  xray_tube_type_tesim: ["X-Ray Tube Type"],
  target_material_tesim: ["Target Material"],
  target_type_tesim: ["Target Type"]
}

FactoryBot.define do
  factory :imaging_event_document, class: "SolrDocument" do
    sequence(:id, 250000) { |n| n.to_s.rjust(9, "0") } # sequence ids starting at '000250000'
    initialize_with { new(IMAGING_EVENT_DOC_ATTRIBUTES.merge({'id': id})) }
    to_create { |instance| ActiveFedora::SolrService.add(instance.to_h, softCommit: true)}
  end
end