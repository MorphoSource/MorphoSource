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
        :title,
        :creator,
        :software,
        :ie_modality,
        # X-ray CT metadata
        :exposure_time,
        :flux_normalization,
        :geometric_calibration,
        :shading_correction,
        :filter,
        :frame_averaging,
        :projections,
        :voltage,
        :power,
        :amperage,
        :surrounding_material,
        :xray_tube_type,
        :target_type,
        :detector_type,
        :detector_configuration,
        :source_object_distance,
        :source_detector_distance,
        :target_material,
        :rotation_number,
        :phase_contrast,
        :optical_magnification,
        # Photogrammetry properties
        :focal_length_type,
        :background_removal,
        # Photogrammetry properties and Photography properties
        :lens_make,
        :lens_model,
        :light_source
    ]

    #self.terms += [:software, :scanner_modality]
    #self.terms -= [:keyword, :license, :rights_statement, :subject, :language, :source, :resource_type]

    self.required_fields = [
        :title,
        :ie_modality
    ]

    self.single_valued_fields = [
        :description,
        :title,
        :creator,
        :ie_modality,
        # X-ray CT metadata
        :exposure_time,
        :flux_normalization,
        :geometric_calibration,
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
        :detector_configuration,
        :source_object_distance,
        :source_detector_distance,
        :target_material,
        :rotation_number,
        :phase_contrast,
        :optical_magnification,
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
        required_fields + [
            :description,
            :creator,
            :software,
            # X-ray CT metadata
            :exposure_time,
            :flux_normalization,
            :geometric_calibration,
            :shading_correction,
            :filter,
            :frame_averaging,
            :projections,
            :voltage,
            :power,
            :amperage,
            :surrounding_material,
            :xray_tube_type,
            :target_type,
            :detector_type,
            :detector_configuration,
            :source_object_distance,
            :source_detector_distance,
            :target_material,
            :rotation_number,
            :phase_contrast,
            :optical_magnification,
            # Photogrammetry properties
            :focal_length_type,
            :background_removal,
            # Photogrammetry properties and Photography properties
            :lens_make,
            :lens_model,
            :light_source
        ]
    end

  end
end
