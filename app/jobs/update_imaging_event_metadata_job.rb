class UpdateImagingEventMetadataJob < UpdateWorkMetadataJob
  def work_properties
    [ 
      :device_id, :physical_object_id, :ie_modality, :software, :exposure_time, :flux_normalization, 
      :pixel_spacing_calibration, :shading_correction, :ie_filter, 
      :frame_averaging, :projections, :voltage, :power, :amperage, 
      :surrounding_material, :xray_tube_type, :target_type, :detector_type, 
      :detector_pixels_x, :detector_pixel_size_x, :detector_pixels_y, 
      :detector_pixel_size_y, :detector_configuration, :source_object_distance, 
      :source_detector_distance, :target_material, :rotation_number, 
      :phase_contrast, :optical_magnification, :acquisition_type, 
      :focal_length_type, :background_removal, :lens_make, :lens_model, 
      :light_source, :focal_length, :aperture_value, :iso_speed_ratings, 
      :shutter_speed, :creator, :contributor, :description
    ] 
  end
end