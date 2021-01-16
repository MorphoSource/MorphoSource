# Generated via
#  `rails generate hyrax:work ImagingEvent`
require 'rails_helper'

RSpec.describe ImagingEvent do

  describe "valid work relationships" do

    it "has BiologicalSpecimen and CulturalHeritageObject as valid parents" do
      expect(subject.valid_parent_concerns).to match_array([BiologicalSpecimen, CulturalHeritageObject])
    end

    it "has Media and ProcessingEvent as valid child concerns" do
      expect(subject.valid_child_concerns).to match_array([Media, ProcessingEvent])
    end

  end

  describe "instance" do
    subject { described_class.new }

    let!(:device) { Device.create(title: ['title'], modality: ['Photogrammetry']) }

    it "is valid with valid attributes" do
          subject.description = ["foo"]
          subject.creator = ["foo"]
          subject.title = ["foo"]
          subject.software = ["foo"]
          subject.ie_modality = device.modality
          subject.device_id = [device.id]
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

    describe 'required attributes' do
      before do
        subject.description = ["foo"]
        subject.creator = ["foo"]
        subject.title = ["foo"]
        subject.software = ["foo"]
        subject.ie_modality = device.modality
        subject.device_id = [device.id]
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
      end
      context 'missing title' do
        it 'is not valid' do
          subject.title = nil
          expect(subject).to_not be_valid
          expect(subject.errors[:title]).to eq(["Your work must have a title."])
        end
      end
      context 'missing device_id' do
        it 'is not valid' do
          subject.device_id = nil
          expect(subject).to_not be_valid
          expect(subject.errors[:device_id]).to eq(["device_id is missing"])
        end
      end
      context 'device_id is invalid' do
        it 'is not valid' do
          subject.device_id = ['123']
          expect(subject).to_not be_valid
          expect(subject.errors[:device_id]).to eq(["A device with id: 123 does not exist."])
        end
      end
      context 'missing ie_modality' do
        it 'is not valid' do
          subject.ie_modality = []
          expect(subject).to_not be_valid
          expect(subject.errors[:ie_modality]).to eq(["ie_modality is missing"])
        end
      end
      context "ie_modality doesn't match device modality" do
        let(:modality)  { "Image" }
        it 'is not valid' do
          subject.ie_modality = [modality]
          expect(subject).to_not be_valid
          expect(subject.errors[:ie_modality]).to eq(["Imaging Event modality \"#{modality}\" does not match parent device modality: #{device.modality.join(', ')}"])
        end
      end
    end
  end
end
