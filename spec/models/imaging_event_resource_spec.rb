# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource ImagingEventResource`
require 'rails_helper'
# require 'hyrax/specs/shared_specs/hydra_works'

RSpec.describe ImagingEventResource do
  subject(:work) { described_class.new }

  # it_behaves_like 'a Hyrax::Work'

  context 'includes schema defined metadata' do
    it { is_expected.to respond_to(:acquisition_type) }
    it { is_expected.to respond_to(:amperage) }
    it { is_expected.to respond_to(:aperture_value) }
    it { is_expected.to respond_to(:background_removal) }
    it { is_expected.to respond_to(:creator) }
    it { is_expected.to respond_to(:date_created) }
    it { is_expected.to respond_to(:description) }
    it { is_expected.to respond_to(:description_attachment_url) }
    it { is_expected.to respond_to(:detector_configuration) }
    it { is_expected.to respond_to(:detector_pixel_size_x) }
    it { is_expected.to respond_to(:detector_pixel_size_y) }
    it { is_expected.to respond_to(:detector_pixels_x) }
    it { is_expected.to respond_to(:detector_pixels_y) }
    it { is_expected.to respond_to(:detector_type) }
    it { is_expected.to respond_to(:device_id) }
    it { is_expected.to respond_to(:exposure_time) }
    it { is_expected.to respond_to(:flux_normalization) }
    it { is_expected.to respond_to(:focal_length_type) }
    it { is_expected.to respond_to(:frame_averaging) }
    it { is_expected.to respond_to(:ie_filter) }
    it { is_expected.to respond_to(:ie_modality) }
    it { is_expected.to respond_to(:lens_make) }
    it { is_expected.to respond_to(:lens_model) }
    it { is_expected.to respond_to(:light_source) }
    it { is_expected.to respond_to(:optical_magnification) }
    it { is_expected.to respond_to(:phase_contrast) }
    it { is_expected.to respond_to(:pixel_spacing_calibration) }
    it { is_expected.to respond_to(:power) }
    it { is_expected.to respond_to(:projections) }
    it { is_expected.to respond_to(:rotation_number) }
    it { is_expected.to respond_to(:shading_correction) }
    it { is_expected.to respond_to(:slide_type) }
    it { is_expected.to respond_to(:software) }
    it { is_expected.to respond_to(:source_detector_distance) }
    it { is_expected.to respond_to(:source_object_distance) }
    it { is_expected.to respond_to(:surrounding_material) }
    it { is_expected.to respond_to(:target_material) }
    it { is_expected.to respond_to(:target_type) }
    it { is_expected.to respond_to(:title) }
    it { is_expected.to respond_to(:voltage) }
    it { is_expected.to respond_to(:xray_tube_type) }
  end
end
