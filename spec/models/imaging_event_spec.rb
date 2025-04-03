# Generated via
#  `rails generate hyrax:work ImagingEvent`
require 'rails_helper'

RSpec.describe ImagingEvent do

  describe "valid work relationships" do

    it "has BiologicalSpecimen and CulturalHeritageObject as valid parents" do
      expect(subject.valid_parent_concerns).to match_array([])
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
          # Slides
          subject.slide_type = ["foo"]
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
        # Slides 
        subject.slide_type = ["foo"]
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

  describe 'media' do
    let(:ie)      { ImagingEvent.create(title: ['ie']) }
    let(:pe)      { ProcessingEvent.create(title: ['pe']) }
    let(:media1)  { Media.create(title: ['media1'] ) }
    let(:media2)  { Media.create(title: ['media2']) }
    let(:works)   { [ie, pe, media1, media2] }

    before do
      ie.ordered_members << media1
      media1.ordered_members << pe
      pe.ordered_members << media2
      works.each(&:save)
    end

    it 'returns all media descendants' do
      expect(ie.media).to match_array([media1, media2])
    end
  end

  describe 'objects' do
    let(:specimen)  { BiologicalSpecimen.create(title: ['specimen'], vouchered: ['Yes']) }
    let(:cho)       { CulturalHeritageObject.create(title: ['cho'], vouchered: ['No']) }
    let(:ie)        { ImagingEvent.create(title: ['ie'], device_id: [device.id], physical_object_id: [specimen.id, cho.id], ie_modality: device.modality) }
    let(:device)    { Device.create(title: ['device'], modality: ['Photogrammetry']) }

    it 'returns all parent objects' do
      expect(ie.objects).to match_array([specimen, cho])
    end
  end

  describe 'description attachment methods' do
    let(:imaging_event) { ImagingEvent.create }
    let(:valid_file) { Rack::Test::UploadedFile.new('spec/fixtures/text/text.txt', 'text/plain') }
    let(:invalid_file) { Rack::Test::UploadedFile.new('spec/fixtures/images/ms.jpg', 'application/jpeg') }
    let(:valid_file_upload_url) { "/uploads/works/imaging_event/attachments/description/text.txt" }
    let(:uploader) { imaging_event.description_uploader }

    describe '#description_uploader' do
      it 'initializes an uploader with the correct work_id' do
        expect(uploader).to be_an_instance_of(ImagingEventDescriptionAttachmentUploader)
        expect(uploader.work_id).to eq(imaging_event.id)
      end
    end

    describe '#description_attachment=' do
      context 'when assigning a valid file' do
        it 'stores the file and sets the description_attachment_url' do
          imaging_event.description_attachment = valid_file
          expect(imaging_event.description_attachment_url).to eq(valid_file_upload_url)
          expect(File.exist?(uploader.file.path)).to be_truthy
        end
      end

      context 'when assigning an invalid file' do
        it 'raises an error for unsupported file format' do
          expect {
            imaging_event.description_attachment = invalid_file
          }.to raise_error(ArgumentError, /Invalid file format: .jpg/)
        end
      end

      context 'when assigning nil' do
        before do
          imaging_event.description_attachment = valid_file
          expect(imaging_event.description_attachment_url).to be_present
        end

        it 'deletes the attachment and clears the description_attachment_url' do
          file_path = uploader.file.path
          expect(File.exist?(file_path)).to be_truthy

          imaging_event.description_attachment = nil
          expect(imaging_event.description_attachment_url).to be_nil
          expect(File.exist?(file_path)).to be_falsey
        end

        it 'logs a warning if the file does not exist' do
          allow(File).to receive(:exist?).and_return(false)
          imaging_event.description_attachment = nil
        end
      end
    end

    describe '#description_attachment' do
      it 'returns the description_attachment_url' do
        imaging_event.description_attachment = valid_file
        expect(imaging_event.description_attachment).to eq(imaging_event.description_attachment_url)
      end
    end
  end

  describe 'reference attachment methods' do
    let(:imaging_event) { ImagingEvent.create }
    let(:valid_file) { Rack::Test::UploadedFile.new('spec/fixtures/images/ms.jpg', 'application/jpeg') }
    let(:invalid_file) { Rack::Test::UploadedFile.new('spec/fixtures/text/text.txt', 'text/plain') }
    let(:valid_file_upload_url) { "/uploads/works/imaging_event/attachments/reference/ms.jpg" }
    let(:uploader) { imaging_event.reference_uploader }

    describe '#reference_uploader' do
      it 'initializes an uploader with the correct work_id' do
        expect(uploader).to be_an_instance_of(ImagingEventReferenceAttachmentUploader)
        expect(uploader.work_id).to eq(imaging_event.id)
      end
    end

    describe '#reference_attachment=' do
      context 'when assigning a valid file' do
        it 'stores the file and sets the reference_attachment_url' do
          imaging_event.reference_attachment = valid_file
          expect(imaging_event.reference_attachment_url).to eq(valid_file_upload_url)
          expect(File.exist?(uploader.file.path)).to be_truthy
        end
      end

      context 'when assigning an invalid file' do
        it 'raises an error for unsupported file format' do
          expect {
            imaging_event.reference_attachment = invalid_file
          }.to raise_error(ArgumentError, /Invalid file format: .txt/)
        end
      end

      context 'when assigning nil' do
        before do
          imaging_event.reference_attachment = valid_file
          expect(imaging_event.reference_attachment_url).to be_present
        end

        it 'deletes the attachment and clears the reference_attachment_url' do
          file_path = uploader.file.path
          expect(File.exist?(file_path)).to be_truthy

          imaging_event.reference_attachment = nil
          expect(imaging_event.reference_attachment_url).to be_nil
          expect(File.exist?(file_path)).to be_falsey
        end

        it 'logs a warning if the file does not exist' do
          allow(File).to receive(:exist?).and_return(false)
          imaging_event.reference_attachment = nil
        end
      end
    end

    describe '#reference_attachment' do
      it 'returns the reference_attachment_url' do
        imaging_event.reference_attachment = valid_file
        expect(imaging_event.reference_attachment).to eq(imaging_event.reference_attachment_url)
      end
    end
  end

end
