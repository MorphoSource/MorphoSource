# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource ImagingEventResource`
require 'rails_helper'
# require 'hyrax/specs/shared_specs/hydra_works'

RSpec.describe ImagingEventResource do
  subject(:work) { described_class.new }

  # it_behaves_like 'a Hyrax::Work'

  # Hyrax::ArResource#save publishes object.deposited/object.metadata.updated
  # events. Listeners such as ContentDepositEventJob attempt to call
  # imaging_event_resource_path, which has no route yet. Stub the publisher
  # to avoid this in model specs.
  before { allow(Hyrax.publisher).to receive(:publish) }

  describe ImagingEventResourceParentDeviceModalityValidator do
    let(:device) { Device.create(title: ['device'], modality: ['Photogrammetry']) }

    subject do
      ImagingEventResource.new(
        title: ['test'],
        device_id: [device.id],
        ie_modality: device.modality
      )
    end

    it 'is valid with a valid device_id and matching modality' do
      expect(subject).to be_valid
    end

    context 'missing device_id' do
      it 'is not valid' do
        subject.device_id = []
        expect(subject).not_to be_valid
        expect(subject.errors[:device_id]).to eq(["device_id is missing"])
      end
    end

    context 'device_id does not exist' do
      it 'is not valid' do
        subject.device_id = ['nonexistent-id']
        expect(subject).not_to be_valid
        expect(subject.errors[:device_id]).to eq(["A device with id: nonexistent-id does not exist."])
      end
    end

    context 'missing ie_modality' do
      it 'is not valid' do
        subject.ie_modality = []
        expect(subject).not_to be_valid
        expect(subject.errors[:ie_modality]).to eq(["ie_modality is missing"])
      end
    end

    context "ie_modality doesn't match device modality" do
      let(:modality) { 'Image' }

      it 'is not valid' do
        subject.ie_modality = [modality]
        expect(subject).not_to be_valid
        expect(subject.errors[:ie_modality]).to eq(["Imaging Event modality \"#{modality}\" does not match parent device modality: #{device.modality.join(', ')}"])
      end
    end
  end

  describe 'description attachment methods' do
    let(:imaging_event) { Hyrax.persister.save(resource: ImagingEventResource.new(title: ['test'])) }
    let(:valid_file) { Rack::Test::UploadedFile.new('spec/fixtures/text/text.txt', 'text/plain') }
    let(:invalid_file) { Rack::Test::UploadedFile.new('spec/fixtures/images/ms.jpg', 'application/jpeg') }
    let(:uploader) { imaging_event.description_uploader }

    describe '#description_uploader' do
      it 'initializes an uploader with the correct work_id' do
        expect(uploader).to be_an_instance_of(ImagingEventDescriptionAttachmentUploader)
        expect(uploader.work_id).to eq(imaging_event.id.to_s)
      end
    end

    describe '#description_attachment=' do
      context 'when assigning a valid file' do
        it 'stores the file and sets description_attachment_url' do
          imaging_event.description_attachment = valid_file
          expect(imaging_event.description_attachment_url).to be_present
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

        it 'deletes the attachment and clears description_attachment_url' do
          file_path = uploader.file.path
          expect(File.exist?(file_path)).to be_truthy

          imaging_event.description_attachment = nil
          expect(imaging_event.description_attachment_url).to be_empty
          expect(File.exist?(file_path)).to be_falsey
        end

        it 'logs a warning if the file does not exist' do
          allow(File).to receive(:exist?).and_return(false)
          imaging_event.description_attachment = nil
        end
      end
    end

    describe '#description_attachment' do
      it 'returns the first description_attachment_url' do
        imaging_event.description_attachment = valid_file
        expect(imaging_event.description_attachment).to eq(imaging_event.description_attachment_url.first)
      end
    end
  end

  describe 'reference attachment methods' do
    let(:imaging_event) { Hyrax.persister.save(resource: ImagingEventResource.new(title: ['test'])) }
    let(:valid_file) { Rack::Test::UploadedFile.new('spec/fixtures/images/ms.jpg', 'application/jpeg') }
    let(:invalid_file) { Rack::Test::UploadedFile.new('spec/fixtures/text/text.txt', 'text/plain') }
    let(:uploader) { imaging_event.reference_uploader }

    describe '#reference_uploader' do
      it 'initializes an uploader with the correct work_id' do
        expect(uploader).to be_an_instance_of(ImagingEventReferenceAttachmentUploader)
        expect(uploader.work_id).to eq(imaging_event.id.to_s)
      end
    end

    describe '#reference_attachment=' do
      context 'when assigning a valid file' do
        it 'stores the file and sets reference_attachment_url' do
          imaging_event.reference_attachment = valid_file
          expect(imaging_event.reference_attachment_url).to be_present
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

        it 'deletes the attachment and clears reference_attachment_url' do
          file_path = uploader.file.path
          expect(File.exist?(file_path)).to be_truthy

          imaging_event.reference_attachment = nil
          expect(imaging_event.reference_attachment_url).to be_empty
          expect(File.exist?(file_path)).to be_falsey
        end

        it 'logs a warning if the file does not exist' do
          allow(File).to receive(:exist?).and_return(false)
          imaging_event.reference_attachment = nil
        end
      end
    end

    describe '#reference_attachment' do
      it 'returns the first reference_attachment_url' do
        imaging_event.reference_attachment = valid_file
        expect(imaging_event.reference_attachment).to eq(imaging_event.reference_attachment_url.first)
      end
    end
  end

  describe '#imaging_event?' do
    it 'returns true' do
      expect(work.imaging_event?).to be true
    end
  end

  describe '#media?' do
    it 'returns false' do
      expect(work.media?).to be false
    end
  end

  describe '#device' do
    let(:device) { Device.create(title: ['device'], modality: ['Photogrammetry']) }
    let(:ie) { ImagingEventResource.new(device_id: [device.id]) }

    it 'returns the device by device_id' do
      expect(ie.device.id.to_s).to eq(device.id)
    end
  end

  describe '#media' do
    let(:ie) { Hyrax.persister.save(resource: ImagingEventResource.new(title: ['ie'])) }
    let(:media1) { Media.create(title: ['media1']) }

    before do
      ie.member_ids = ie.member_ids + [Valkyrie::ID.new(media1.id)]
      Hyrax.persister.save(resource: ie)
    end

    it 'returns Media members' do
      expect(ie.media.map { |m| m.id.to_s }).to include(media1.id)
    end
  end

  describe '#objects' do
    let(:specimen) { BiologicalSpecimen.create(title: ['specimen'], vouchered: ['Yes']) }
    let(:ie) { ImagingEventResource.new(physical_object_id: [specimen.id]) }

    it 'returns physical objects by physical_object_id' do
      expect(ie.objects.map { |o| o.id.to_s }).to include(specimen.id)
    end
  end

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
