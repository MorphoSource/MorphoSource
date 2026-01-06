# frozen_string_literal: true

# Indexes Hyrax::FileSet resources
class FileSetIndexer < Hyrax::Indexers::FileSetIndexer
   def to_solr
      super.tap do |solr_doc|
        solr_doc['mime_type_ssi'] = resource.is_remote_backed? ? resource.mime_type_of_remote : resource.mime_type
        solr_doc['remote_manifest_url_ssi'] = resource.remote_manifest_url
        solr_doc['download_access_group_ssim'] = resource.download_groups
        solr_doc['download_access_person_ssim'] = resource.download_users
        solr_doc['crc32_tesim'] = resource.crc32
        # images
        solr_doc['bits_per_sample_tesim'] = resource.bits_per_sample
        solr_doc['focal_length_tesim'] = resource.focal_length
        solr_doc['iso_speed_ratings_tesim'] = resource.iso_speed_ratings
        solr_doc['aperture_value_tesim'] = resource.aperture_value
        solr_doc['shutter_speed_tesim'] = resource.shutter_speed

        solr_doc['color_space_tesim'] = resource.color_space
        solr_doc['compression_tesim'] = resource.compression
        # dicom
        solr_doc['spacing_between_slices_tesim'] = resource.spacing_between_slices
        solr_doc['modality_tesim'] = resource.modality
        solr_doc['secondary_capture_device_manufacturer_tesim'] = resource.secondary_capture_device_manufacturer
        solr_doc['secondary_capture_device_software_vers_tesim'] = resource.secondary_capture_device_software_vers
        solr_doc['file_type_extension_tesim'] = resource.file_type_extension
        solr_doc['image_type_tesim'] = resource.image_type
        solr_doc['study_date_tesim'] = resource.study_date
        solr_doc['series_date_tesim'] = resource.series_date
        solr_doc['content_date_tesim'] = resource.content_date
        solr_doc['study_time_tesim'] = resource.study_time
        solr_doc['series_time_tesim'] = resource.series_time
        solr_doc['content_time_tesim'] = resource.content_time
        solr_doc['accession_number_tesim'] = resource.accession_number
        solr_doc['instance_number_tesim'] = resource.instance_number
        solr_doc['image_position_patient_tesim'] = resource.image_position_patient
        solr_doc['image_orientation_patient_tesim'] = resource.image_orientation_patient
        solr_doc['samples_per_pixel_tesim'] = resource.samples_per_pixel
        solr_doc['photometric_interpretation_tesim'] = resource.photometric_interpretation
        solr_doc['rows_tesim'] = resource.rows
        solr_doc['columns_tesim'] = resource.columns
        solr_doc['pixel_spacing_tesim'] = resource.pixel_spacing
        solr_doc['slice_thickness_tesim'] = resource.slice_thickness
        solr_doc['bits_allocated_tesim'] = resource.bits_allocated
        solr_doc['bits_stored_tesim'] = resource.bits_stored
        solr_doc['high_bit_tesim'] = resource.high_bit
        solr_doc['pixel_representation_tesim'] = resource.pixel_representation
        solr_doc['window_center_tesim'] = resource.window_center
        solr_doc['window_width_tesim'] = resource.window_width
        solr_doc['rescale_intercept_tesim'] = resource.rescale_intercept
        solr_doc['rescale_slope_tesim'] = resource.rescale_slope
        solr_doc['window_center_and_width_explanation_tesim'] = resource.window_center_and_width_explanation

        solr_doc['exposure_time_tesim'] = resource.exposure_time
        solr_doc['pixel_spacing_calibration_type_tesim'] = resource.pixel_spacing_calibration_type
        solr_doc['contrast_frame_averaging_tesim'] = resource.contrast_frame_averaging
        solr_doc['images_in_acquisition_tesim'] = resource.images_in_acquisition
        solr_doc['KVP_tesim'] = resource.KVP
        solr_doc['generator_power_tesim'] = resource.generator_power
        solr_doc['x_ray_tube_current_tesim'] = resource.x_ray_tube_current
        solr_doc['container_description_tesim'] = resource.container_description
        solr_doc['generator_id_tesim'] = resource.generator_id
        solr_doc['detector_description_tesim'] = resource.detector_description
        solr_doc['distance_source_to_patient_tesim'] = resource.distance_source_to_patient
        solr_doc['distance_source_to_detector_tesim'] = resource.distance_source_to_detector
        solr_doc['anode_target_material_tesim'] = resource.anode_target_material
        solr_doc['spiral_pitch_factor_tesim'] = resource.spiral_pitch_factor
        solr_doc['number_of_series_related_instances_tesim'] = resource.number_of_series_related_instances

        # mesh
        solr_doc['point_count_tesim'] = resource.point_count
        solr_doc['face_count_tesim'] = resource.face_count
        solr_doc['edges_per_face_tesim'] = resource.edges_per_face
        solr_doc['bounding_box_x_tesim'] = resource.bounding_box_x
        solr_doc['bounding_box_y_tesim'] = resource.bounding_box_y
        solr_doc['bounding_box_z_tesim'] = resource.bounding_box_z
        solr_doc['color_format_tesim'] = resource.color_format
        solr_doc['normals_format_tesim'] = resource.normals_format
        solr_doc['has_uv_space_tesim'] = resource.has_uv_space
        solr_doc['vertex_color_tesim'] = resource.vertex_color
        solr_doc['centroid_x_tesim'] = resource.centroid_x
        solr_doc['centroid_y_tesim'] = resource.centroid_y
        solr_doc['centroid_z_tesim'] = resource.centroid_z
        solr_doc['centroid_method_tesim'] = resource.centroid_method
        solr_doc['blender_version_tesim'] = resource.blender_version
        solr_doc['gltf_inspect_version_tesim'] = resource.gltf_inspect_version
        solr_doc['pymeshlab_version_tesim'] = resource.pymeshlab_version

        # zip archive contents
        solr_doc['contents_all_files_ss'] = resource.contents_all_files
        solr_doc['contents_mime_type_tesim'] = resource.contents_mime_type
        solr_doc['contents_file_name_tesim'] = resource.contents_file_name
        solr_doc['contents_file_size_tesim'] = resource.contents_file_size
        solr_doc['contents_accepted_file_count_tesim'] = resource.contents_accepted_file_count
     end
   end
end