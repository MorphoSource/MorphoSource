# Generated via
#  `rails generate hyrax:work ImageCaptureEvent`
module Hyrax
  class ImageCaptureEventPresenter < Hyrax::WorkShowPresenter
    delegate  :description, 
            :creator,
            :title,
            :software,
            :ice_modality,
            # X-ray CT metadata
            :exposure_time,
            :flux_normalization,
            :geometric_calibration,
            :shading_correction,
            :filter_material, 
            :filter_thickness,
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
            :light_source,
        to: :solr_document
  end
end
