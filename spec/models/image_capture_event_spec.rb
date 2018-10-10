# Generated via
#  `rails generate hyraxsubject.work ImageCaptureEvent`
require 'rails_helper'

RSpec.describe ImageCaptureEvent do
  subject { described_class.new }

  it "is valid with valid attributes" do
        subject.description = ["foo"]
        subject.creator = ["foo"]
        subject.title = ["foo"]
        subject.software = ["foo"]
        subject.ice_modality = ["foo"]
        # X-ray CT metadata
        subject.exposure_time = ["foo"]
        subject.flux_normalization = ["foo"]
        subject.geometric_calibration = ["foo"]
        subject.shading_correction = ["foo"]
        subject.filter_material = ["foo"]
        subject.filter_thickness = ["foo"]
        subject.frame_averaging = ["foo"]
        subject.projections = ["foo"]
        subject.voltage = ["foo"]
        subject.power = ["foo"]
        subject.amperage = ["foo"]
        subject.surrounding_material = ["foo"]
        subject.xray_tube_type = ["foo"]
        subject.target_type = ["foo"]
        subject.detector_type = ["foo"]
        subject.detector_configuration = ["foo"]
        subject.source_object_distance = ["foo"]
        subject.source_detector_distance = ["foo"]
        subject.target_material = ["foo"]
        subject.rotation_number = ["foo"]
        subject.phase_contrast = ["foo"]
        subject.optical_magnification = ["foo"]
        # Photogrammetry properties
        subject.focal_length_type = ["foo"]
        subject.background_removal = ["foo"]
        # Photogrammetry properties and Photography properties
        subject.lens_make = ["foo"]
        subject.lens_model = ["foo"]
        subject.light_source = ["foo"]
        expect(subject).to be_valid
  end

  it "is not valid without required fields - title, ice_modality" do
        subject.description = ["foo"]
        subject.creator = ["foo"]
        subject.title = nil
        subject.software = ["foo"]
        subject.ice_modality = nil
        # X-ray CT metadata
        subject.exposure_time = ["foo"]
        subject.flux_normalization = ["foo"]
        subject.geometric_calibration = ["foo"]
        subject.shading_correction = ["foo"]
        subject.filter_material = ["foo"]
        subject.filter_thickness = ["foo"]
        subject.frame_averaging = ["foo"]
        subject.projections = ["foo"]
        subject.voltage = ["foo"]
        subject.power = ["foo"]
        subject.amperage = ["foo"]
        subject.surrounding_material = ["foo"]
        subject.xray_tube_type = ["foo"]
        subject.target_type = ["foo"]
        subject.detector_type = ["foo"]
        subject.detector_configuration = ["foo"]
        subject.source_object_distance = ["foo"]
        subject.source_detector_distance = ["foo"]
        subject.target_material = ["foo"]
        subject.rotation_number = ["foo"]
        subject.phase_contrast = ["foo"]
        subject.optical_magnification = ["foo"]
        # Photogrammetry properties
        subject.focal_length_type = ["foo"]
        subject.background_removal = ["foo"]
        # Photogrammetry properties and Photography properties
        subject.lens_make = ["foo"]
        subject.lens_model = ["foo"]
        subject.light_source = ["foo"]
        expect(subject).to_not be_valid
  end

end
