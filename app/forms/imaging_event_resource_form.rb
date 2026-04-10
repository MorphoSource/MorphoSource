# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource ImagingEventResource`
#
# @see https://github.com/samvera/hyrax/wiki/Hyrax-Valkyrie-Usage-Guide#forms
# @see https://github.com/samvera/valkyrie/wiki/ChangeSets-and-Dirty-Tracking
class ImagingEventResourceForm < Hyrax::Forms::PcdmObjectForm(ImagingEventResource)
  include Hyrax::FormFields(:basic_metadata)
  include Hyrax::FormFields(:imaging_event_resource)
  include Morphosource::FormMethods
  include Morphosource::ValkyrieFormBehavior

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

  # title is required by core_metadata form validation but is auto-generated
  # in sync(). Inject ie_modality as a placeholder so the presence validator
  # passes when no explicit title is submitted (the normal case).
  def validate(params)
    params = (params || {}).to_h
    unless params['title']&.any?(&:present?)
      modality = Array(params['ie_modality']).first.to_s
      params = params.merge('title' => [modality])
    end
    super(params)
  end

  # Pre-assign the resource ID so the IE title prefix can be applied before
  # the persister save. The Valkyrie Postgres persister honours a pre-assigned
  # Valkyrie::ID as the primary key rather than generating a new one, so the
  # resource is stored with the correct title on the first (and only) save.
  # This is necessary because CreateWorkService uses the persister directly
  # (bypassing ImagingEventResource#save) and the ID is nil until that first
  # persister save.
  def sync
    result = super
    result.id = Valkyrie::ID.new(SecureRandom.uuid) if result.id.nil?
    result.apply_id_title_prefix if result.needs_id_title_prefix?
    result
  end

  # Required by Hyrax::Forms::FailedSubmissionFormWrapper when create fails and
  # the form is rebuilt for re-display. Returns the fields that can be
  # re-populated from the submitted params.
  def self.build_permitted_params
    [
      :on_behalf_of, :visibility, :agreement_accepted, :admin_set_id,
      :ie_modality, :description, :software, :date_created,
      :device_id, :physical_object_id,
      :exposure_time, :flux_normalization, :pixel_spacing_calibration,
      :shading_correction, :frame_averaging, :projections, :voltage, :power,
      :amperage, :surrounding_material, :xray_tube_type, :target_type,
      :detector_type, :detector_pixels_x, :detector_pixel_size_x,
      :detector_pixels_y, :detector_pixel_size_y, :detector_configuration,
      :source_object_distance, :source_detector_distance, :target_material,
      :rotation_number, :phase_contrast, :optical_magnification,
      :acquisition_type, :focal_length_type, :background_removal,
      :lens_make, :lens_model, :light_source, :slide_type, :aperture_value,
      { title: [] }, { creator: [] }, { ie_filter: [] },
      { member_of_collection_ids: [] },
      { work_parents_attributes: [:id, :_destroy] }
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
