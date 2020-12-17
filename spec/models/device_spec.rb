# Generated via
#  `rails generate hyrax:work Device`
require 'rails_helper'

RSpec.describe Device do

  it_behaves_like 'a Morphosource work'

  describe "metadata attributes" do
    it "include the appropriate terms" do
      expect(subject.attributes).to include('title', 'creator', 'modality', 'description')
    end
  end

  describe "valid work relationships" do

    it "has only Organization as a valid parent" do
      expect(subject.valid_parent_concerns).to match_array([Organization])
    end

    it "has no valid child concerns" do
      expect(subject.valid_child_concerns).to match_array([])
    end

  end

  describe "instance" do
    subject { Device.new({
        title: ['XTekCT 100'],
        creator: ['Nikon'],
        modality: ['MicroNanoXRayComputedTomography'],
        description: ['A sample description']
      })
    }
    it "creates with correct title" do
      expect(subject.title.first).to eq('XTekCT 100')
    end
    it "creates with correct creator" do
      expect(subject.creator.first).to eq('Nikon')
    end
    it "creates with correct modality" do
      expect(subject.modality.first).to eq('MicroNanoXRayComputedTomography')
    end
    it "creates with correct description" do
      expect(subject.description.first).to eq('A sample description')
    end

    describe "valid work relationships" do

      it "has only Organization as a valid parent" do
        expect(subject.valid_parent_concerns).to match_array([Organization])
      end

      it "has ImagingEvent as valid child concerns" do
        expect(subject.valid_child_concerns).to match_array([])
      end

    end

  end

end
