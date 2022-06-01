module Morphosource
  module Solr
    module FileSet

      DICOM_PROPERTIES = %w[accession_number
                            anode_target_material
                            bits_allocated
                            bits_stored
                            columns
                            container_description
                            content_date
                            content_time
                            contrast_frame_averaging
                            detector_description
                            distance_source_to_detector
                            distance_source_to_patient
                            exposure_time
                            file_type_extension
                            generator_id
                            generator_power
                            high_bit
                            image_orientation_patient
                            image_position_patient
                            image_type
                            images_in_acquisition
                            instance_number
                            KVP
                            modality
                            number_of_series_related_instance
                            photometric_interpretation
                            pixel_representation
                            pixel_spacing
                            pixel_spacing_calibration_type
                            rescale_intercept
                            rescale_slope
                            rows
                            samples_per_pixel
                            secondary_capture_device_manufacturer
                            secondary_capture_device_software_vers
                            series_date
                            series_time
                            spacing_between_slices
                            spiral_pitch_factor
                            study_date
                            study_time
                            window_center
                            window_center_and_width_explanation
                            window_width
                            x_ray_tube_current]

      IMAGE_PROPERTIES = %w[bits_per_sample
                           color_space
                           compression]

      MESH_PROPERTIES = %w[bounding_box_x
                           bounding_box_y
                           bounding_box_z
                           centroid_x
                           centroid_y
                           centroid_z
                           color_format
                           edges_per_face
                           face_count
                           has_uv_space
                           normals_format
                           point_count
                           vertex_color]

      ZIP_PROPERTIES = %w[contents_accepted_file_count
                          contents_file_name
                          contents_file_size
                          contents_mime_type]

      # these values are delegated to the charactetrization proxy
      FILE_SET_PROPERTIES = ["crc32",
                             DICOM_PROPERTIES,
                             IMAGE_PROPERTIES,
                             MESH_PROPERTIES,
                             ZIP_PROPERTIES].flatten

    end
  end
end
