# override `generate_solr_document` by calling super and indexing the other fields you care about.
class MsFileSetIndexer < Hyrax::FileSetIndexer
  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['mime_type_ssi'] = object.is_remote_backed? ? object.mime_type_of_remote : object.mime_type
      solr_doc['download_access_group_ssim'] = object.download_groups
      solr_doc['download_access_person_ssim'] = object.download_users
      solr_doc['crc32_tesim'] = object.crc32
      # images
      solr_doc['bits_per_sample_tesim'] = object.bits_per_sample
      solr_doc['focal_length_tesim'] = object.focal_length
      solr_doc['iso_speed_ratings_tesim'] = object.iso_speed_ratings
      solr_doc['aperture_value_tesim'] = object.aperture_value
      solr_doc['shutter_speed_tesim'] = object.shutter_speed

      solr_doc['color_space_tesim'] = object.color_space
      solr_doc['compression_tesim'] = object.compression
      # dicom
      solr_doc['spacing_between_slices_tesim'] = object.spacing_between_slices
      solr_doc['modality_tesim'] = object.modality
      solr_doc['secondary_capture_device_manufacturer_tesim'] = object.secondary_capture_device_manufacturer
      solr_doc['secondary_capture_device_software_vers_tesim'] = object.secondary_capture_device_software_vers
      solr_doc['file_type_extension_tesim'] = object.file_type_extension
      solr_doc['image_type_tesim'] = object.image_type
      solr_doc['study_date_tesim'] = object.study_date
      solr_doc['series_date_tesim'] = object.series_date
      solr_doc['content_date_tesim'] = object.content_date
      solr_doc['study_time_tesim'] = object.study_time
      solr_doc['series_time_tesim'] = object.series_time
      solr_doc['content_time_tesim'] = object.content_time
      solr_doc['accession_number_tesim'] = object.accession_number
      solr_doc['instance_number_tesim'] = object.instance_number
      solr_doc['image_position_patient_tesim'] = object.image_position_patient
      solr_doc['image_orientation_patient_tesim'] = object.image_orientation_patient
      solr_doc['samples_per_pixel_tesim'] = object.samples_per_pixel
      solr_doc['photometric_interpretation_tesim'] = object.photometric_interpretation
      solr_doc['rows_tesim'] = object.rows
      solr_doc['columns_tesim'] = object.columns
      solr_doc['pixel_spacing_tesim'] = object.pixel_spacing
      solr_doc['slice_thickness_tesim'] = object.slice_thickness
      solr_doc['bits_allocated_tesim'] = object.bits_allocated
      solr_doc['bits_stored_tesim'] = object.bits_stored
      solr_doc['high_bit_tesim'] = object.high_bit
      solr_doc['pixel_representation_tesim'] = object.pixel_representation
      solr_doc['window_center_tesim'] = object.window_center
      solr_doc['window_width_tesim'] = object.window_width
      solr_doc['rescale_intercept_tesim'] = object.rescale_intercept
      solr_doc['rescale_slope_tesim'] = object.rescale_slope
      solr_doc['window_center_and_width_explanation_tesim'] = object.window_center_and_width_explanation

      solr_doc['exposure_time_tesim'] = object.exposure_time
      solr_doc['pixel_spacing_calibration_type_tesim'] = object.pixel_spacing_calibration_type
      solr_doc['contrast_frame_averaging_tesim'] = object.contrast_frame_averaging
      solr_doc['images_in_acquisition_tesim'] = object.images_in_acquisition
      solr_doc['KVP_tesim'] = object.KVP
      solr_doc['generator_power_tesim'] = object.generator_power
      solr_doc['x_ray_tube_current_tesim'] = object.x_ray_tube_current
      solr_doc['container_description_tesim'] = object.container_description
      solr_doc['generator_id_tesim'] = object.generator_id
      solr_doc['detector_description_tesim'] = object.detector_description
      solr_doc['distance_source_to_patient_tesim'] = object.distance_source_to_patient
      solr_doc['distance_source_to_detector_tesim'] = object.distance_source_to_detector
      solr_doc['anode_target_material_tesim'] = object.anode_target_material
      solr_doc['spiral_pitch_factor_tesim'] = object.spiral_pitch_factor
      solr_doc['number_of_series_related_instances_tesim'] = object.number_of_series_related_instances

      # mesh
      solr_doc['point_count_tesim'] = object.point_count
      solr_doc['face_count_tesim'] = object.face_count
      solr_doc['edges_per_face_tesim'] = object.edges_per_face
      solr_doc['bounding_box_x_tesim'] = object.bounding_box_x
      solr_doc['bounding_box_y_tesim'] = object.bounding_box_y
      solr_doc['bounding_box_z_tesim'] = object.bounding_box_z
      solr_doc['color_format_tesim'] = object.color_format
      solr_doc['normals_format_tesim'] = object.normals_format
      solr_doc['has_uv_space_tesim'] = object.has_uv_space
      solr_doc['vertex_color_tesim'] = object.vertex_color
      solr_doc['centroid_x_tesim'] = object.centroid_x
      solr_doc['centroid_y_tesim'] = object.centroid_y
      solr_doc['centroid_z_tesim'] = object.centroid_z
      # zip archive contents
      solr_doc['contents_mime_type_tesim'] = object.contents_mime_type
      solr_doc['contents_file_name_tesim'] = object.contents_file_name
      solr_doc['contents_file_size_tesim'] = object.contents_file_size
      solr_doc['contents_accepted_file_count_tesim'] = object.contents_accepted_file_count
    end
  end
end
