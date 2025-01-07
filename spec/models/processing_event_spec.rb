# Generated via
#  `rails generate hyrax:work ProcessingEvent`
require 'rails_helper'

RSpec.describe ProcessingEvent do

  it_behaves_like 'a Morphosource work'

  describe 'metadata' do

    it "has descriptive metadata" do

      expect(subject).to respond_to(:creator)
      expect(subject).to respond_to(:date_created)
      expect(subject).to respond_to(:description)
      expect(subject).to respond_to(:software)
      expect(subject).to respond_to(:title)

    end

  end

  describe "valid work relationships" do

    it "has Media and ImagingEvent as valid parents" do
      expect(subject.valid_parent_concerns).to match_array([Media, ImagingEvent])
    end

    it "has Media as valid child" do
      expect(subject.valid_child_concerns).to match_array([Media])
    end

  end

  describe "instance" do

    subject { ProcessingEvent.new({
        title: ['Test Attachment']
      })
    }

    describe "valid work relationships" do

      it "has Media and ImagingEvent as valid parents" do
        expect(subject.valid_parent_concerns).to match_array([Media, ImagingEvent])
      end

      it "has Media as valid child" do
        expect(subject.valid_child_concerns).to match_array([Media])
      end

    end

  end

  describe 'media and objects' do
    let(:cho)           { CulturalHeritageObject.create(title: ['cho'], vouchered: ['Yes']) }
    let(:device)        { Device.create(title: ['device'], modality: ['Photogrammetry']) }
    let(:imaging_event) { ImagingEvent.create(title: ['ie'], ie_modality: device.modality, device_id: [device.id], physical_object_id: [cho.id]) }
    let(:pe1)           { ProcessingEvent.create(title: ['pe1']) }
    let(:media1)        { Media.create(title: ['media1']) }
    let(:pe2)           { ProcessingEvent.create(title: ['pe2']) }
    let(:media2)        { Media.create(title: ['media2']) }
    let(:pe3)           { ProcessingEvent.create(title: ['pe3']) }
    let(:media3)        { Media.create(title: ['media3']) }

    before do
      imaging_event.ordered_members << media1
      media1.ordered_members << pe1
      pe1.ordered_members << media2
      media2.ordered_members << pe3
      pe3.ordered_members << media3
      [imaging_event, pe1, media1, pe2, media2, pe3, media3].each(&:save)
    end

    it 'returns all descendant media and parent objects' do
      expect(pe1.media).to match_array([media2, media3])
      expect(pe1.objects).to match_array([cho])
    end
  end

  describe 'description attachment methods' do
    let(:processing_event) { ProcessingEvent.create }
    let(:valid_file) { Rack::Test::UploadedFile.new('spec/fixtures/text/text.txt', 'text/plain') }
    let(:invalid_file) { Rack::Test::UploadedFile.new('spec/fixtures/images/ms.jpg', 'application/jpeg') }
    let(:valid_file_upload_url) { "/works/processing_event/attachments/text.txt" }

    describe '#uploader' do
      it 'initializes an uploader with the correct work_id' do
        uploader = processing_event.uploader
        expect(uploader).to be_an_instance_of(ProcessingEventAttachmentUploader)
        expect(uploader.work_id).to eq(processing_event.id)
      end
    end

    describe '#description_attachment=' do
      context 'when assigning a valid file' do
        it 'stores the file and sets the description_attachment_url' do
          processing_event.description_attachment = valid_file
          expect(processing_event.description_attachment_url).to eq(valid_file_upload_url)
          expect(File.exist?(processing_event.uploader.file.path)).to be_truthy
        end
      end

      context 'when assigning an invalid file' do
        it 'raises an error for unsupported file format' do
          expect {
            processing_event.description_attachment = invalid_file
          }.to raise_error(ArgumentError, /Invalid file format: .jpg/)
        end
      end

      context 'when assigning nil' do
        before do
          processing_event.description_attachment = valid_file
          expect(processing_event.description_attachment_url).to be_present
        end

        it 'deletes the attachment and clears the description_attachment_url' do
          file_path = processing_event.uploader.file.path
          expect(File.exist?(file_path)).to be_truthy

          processing_event.description_attachment = nil
          expect(processing_event.description_attachment_url).to be_nil
          expect(File.exist?(file_path)).to be_falsey
        end

        it 'logs a warning if the file does not exist' do
          allow(File).to receive(:exist?).and_return(false)
          expect(Rails.logger).to receive(:warn).with(/File not found/)
          processing_event.description_attachment = nil
        end
      end
    end

    describe '#description_attachment' do
      it 'returns the description_attachment_url' do
        processing_event.description_attachment = valid_file
        expect(processing_event.description_attachment).to eq(processing_event.description_attachment_url)
      end
    end
  end

end
