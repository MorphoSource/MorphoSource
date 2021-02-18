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

end
