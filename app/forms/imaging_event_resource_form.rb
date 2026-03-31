# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource ImagingEventResource`
#
# @see https://github.com/samvera/hyrax/wiki/Hyrax-Valkyrie-Usage-Guide#forms
# @see https://github.com/samvera/valkyrie/wiki/ChangeSets-and-Dirty-Tracking
class ImagingEventResourceForm < Hyrax::Forms::PcdmObjectForm(ImagingEventResource)
  include Hyrax::FormFields(:basic_metadata)
  include Hyrax::FormFields(:imaging_event_resource)

  # Mirrors Hyrax::ImagingEventForm#primary_terms. device_id and physical_object_id
  # are excluded here because they are injected by the controller (submissions or
  # media_owner_update), not entered directly by the user in the form.
  def primary_terms
    [
      :ie_modality,
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
      # Photogrammetry and Photography properties
      :lens_make,
      :lens_model,
      :light_source,
      # Slide scan properties
      :slide_type
    ]
  end

  # Fields shown for all imaging events regardless of modality (left column).
  def universal_terms
    primary_terms[..4]
  end

  # Fields specific to a modality (right column).
  def modality_specific_terms
    primary_terms[5..]
  end
end
