# Generated via
#  `rails generate hyrax:work ImagingEvent`
require 'rails_helper'

RSpec.describe ImagingEvent do

  describe "valid work relationships" do

    it "has Device, BiologicalSpecimen, and CulturalHeritageObject as valid parents" do
      expect(subject.valid_parent_concerns).to match_array([Device, BiologicalSpecimen, CulturalHeritageObject])
    end

    it "has Media and ProcessingEvent as valid child concerns" do
      expect(subject.valid_child_concerns).to match_array([Media, ProcessingEvent])
    end

  end

  describe "instance" do
    subject { described_class.new }

    it "is valid with valid attributes" do
          subject.description = ["foo"]
          subject.creator = ["foo"]
          subject.title = ["foo"]
          subject.software = ["foo"]
          subject.ie_modality = ["foo"]
          # X-ray CT metadata
          subject.exposure_time = ["foo"]
          subject.flux_normalization = ["foo"]
          subject.pixel_spacing_calibration = ["foo"]
          subject.shading_correction = ["foo"]
          subject.ie_filter = ["foo"]
          subject.frame_averaging = ["foo"]
          subject.projections = ["foo"]
          subject.voltage = ["foo"]
          subject.power = ["foo"]
          subject.amperage = ["foo"]
          subject.surrounding_material = ["foo"]
          subject.xray_tube_type = ["foo"]
          subject.target_type = ["foo"]
          subject.detector_type = ["foo"]
          subject.detector_pixels_x = ["foo"]
          subject.detector_pixel_size_x = ["foo"]
          subject.detector_pixels_y = ["foo"]
          subject.detector_pixel_size_y = ["foo"]
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

    it "is not valid without required fields - title, ie_modality" do
          subject.description = ["foo"]
          subject.creator = ["foo"]
          subject.title = nil
          subject.software = ["foo"]
          subject.ie_modality = nil
          # X-ray CT metadata
          subject.exposure_time = ["foo"]
          subject.flux_normalization = ["foo"]
          subject.pixel_spacing_calibration = ["foo"]
          subject.shading_correction = ["foo"]
          subject.ie_filter = ["foo"]
          subject.frame_averaging = ["foo"]
          subject.projections = ["foo"]
          subject.voltage = ["foo"]
          subject.power = ["foo"]
          subject.amperage = ["foo"]
          subject.surrounding_material = ["foo"]
          subject.xray_tube_type = ["foo"]
          subject.target_type = ["foo"]
          subject.detector_type = ["foo"]
          subject.detector_pixels_x = ["foo"]
          subject.detector_pixel_size_x = ["foo"]
          subject.detector_pixels_y = ["foo"]
          subject.detector_pixel_size_y = ["foo"]
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

    describe "valid work relationships" do

      it "has Device, BiologicalSpecimen, and CulturalHeritageObject as valid parents" do
        expect(subject.valid_parent_concerns).to match_array([Device, BiologicalSpecimen, CulturalHeritageObject])
      end

      it "has Media and ProcessingEvent as valid child concerns" do
        expect(subject.valid_child_concerns).to match_array([Media, ProcessingEvent])
      end

    end

  end

end
