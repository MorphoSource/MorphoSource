# Generated via
#  `rails generate hyrax:work ImagingEvent`
module Hyrax
  # Generated form for ImagingEvent
  class ImagingEventForm < Hyrax::Forms::WorkForm

    include SingleValuedForm

    include Morphosource::FormMethods
    include ChildCreateButton

    class_attribute :single_value_fields

    self.model_class = ::ImagingEvent

    self.terms = [
        :description,
        :creator,
        :software,
        :ie_modality,
        :date_created,
        :device_id,
        # X-ray CT metadata
        :exposure_time,
        :flux_normalization,
        :pixel_spacing_calibration,
        :shading_correction,
        :ie_filter,
        :frame_averaging,
        :projections,
        :voltage,
        :power,
        :amperage,
        :surrounding_material,
        :xray_tube_type,
        :target_type,
        :detector_type,
        :detector_pixels_x,
        :detector_pixel_size_x,
        :detector_pixels_y,
        :detector_pixel_size_y,
        :detector_configuration,
        :source_object_distance,
        :source_detector_distance,
        :target_material,
        :rotation_number,
        :phase_contrast,
        :optical_magnification,
        :acquisition_type,
        # Photogrammetry properties
        :focal_length_type,
        :background_removal,
        # Photogrammetry properties and Photography properties
        :lens_make,
        :lens_model,
        :light_source,
        :focal_length,
        :aperture_value,
        :iso_speed_ratings,
        :shutter_speed
    ]

    #self.terms += [:software, :scanner_modality]
    #self.terms -= [:keyword, :license, :rights_statement, :subject, :language, :source, :resource_type]

    self.required_fields = [
        :ie_modality,
        :device_id
    ]

    self.single_valued_fields = [
        :description,
        :creator,
        :ie_modality,
        :device_id,
        :date_created,
        # X-ray CT metadata
        :exposure_time,
        :flux_normalization,
        :pixel_spacing_calibration,
        :shading_correction,
        :frame_averaging,
        :projections,
        :voltage,
        :power,
        :amperage,
        :surrounding_material,
        :xray_tube_type,
        :target_type,
        :detector_type,
        :detector_pixels_x,
        :detector_pixel_size_x,
        :detector_pixels_y,
        :detector_pixel_size_y,
        :detector_configuration,
        :source_object_distance,
        :source_detector_distance,
        :target_material,
        :rotation_number,
        :phase_contrast,
        :optical_magnification,
        :acquisition_type,
        # Photogrammetry properties
        :focal_length_type,
        :background_removal,
        # Photogrammetry properties and Photography properties
        :lens_make,
        :lens_model,
        :light_source
    ]

    # These show above the fold
    def primary_terms
        required_fields - [:device_id] + [
            :description,
            :creator,
            :software,
            :date_created,
            # X-ray CT metadata
            :exposure_time,
            :flux_normalization,
            :pixel_spacing_calibration,
            :shading_correction,
            :ie_filter,
            :frame_averaging,
            :projections,
            :voltage,
            :power,
            :amperage,
            :surrounding_material,
            :xray_tube_type,
            :target_type,
            :detector_type,
            :detector_pixels_x,
            :detector_pixel_size_x,
            :detector_pixels_y,
            :detector_pixel_size_y,
            :detector_configuration,
            :source_object_distance,
            :source_detector_distance,
            :target_material,
            :rotation_number,
            :phase_contrast,
            :optical_magnification,
            :acquisition_type,
            # Photogrammetry properties
            :focal_length_type,
            :background_removal,
            # Photogrammetry properties and Photography properties
            :lens_make,
            :lens_model,
            :light_source
        ]
    end

    def secondary_terms
      []
    end

    def self.build_permitted_params
      super + [:device_id]
    end

  end
end
