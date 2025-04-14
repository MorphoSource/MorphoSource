module Morphosource
  module Solr
    module ImagingEvent

      IMAGING_EVENT_PROPERTIES = %w[acquisition_type
                                    amperage
                                    aperture_value
                                    background_removal
                                    detector_configuration
                                    detector_pixel_size_x
                                    detector_pixel_size_y
                                    detector_pixels_x
                                    detector_pixels_y
                                    detector_type
                                    device_id
                                    exposure_time
                                    flux_normalization
                                    focal_length
                                    focal_length_type
                                    frame_averaging
                                    ie_filter
                                    ie_modality
                                    iso_speed_ratings
                                    lens_make
                                    lens_model
                                    light_source
                                    optical_magnification
                                    phase_contrast
                                    physical_object_id
                                    pixel_spacing_calibration
                                    power
                                    projections
                                    rotation_number
                                    shading_correction
                                    shutter_speed
                                    slide_type
                                    source_detector_distance
                                    source_object_distance
                                    surrounding_material
                                    target_material
                                    target_type
                                    voltage
                                    xray_tube_type
                                    description_attachment_url
                                    reference_attachment_url].freeze

      def imaging_event?
        self['has_model_ssim'] == ['ImagingEvent']
      end
    end
  end
end
