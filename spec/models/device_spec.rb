# Generated via
#  `rails generate hyrax:work Device`
require 'rails_helper'

RSpec.describe Device do

  it_behaves_like 'a Morphosource work'

  describe "metadata attributes" do
    it "include the appropriate terms" do
      expect(subject.attributes).to include('title', 'creator', 'modality', 'facility', 'description')
    end
  end

  describe "instance" do
    subject { Device.new({
        title: ['XTekCT 100'],
        creator: ['Nikon'],
        modality: ['MedicalXRayComputedTomography'],
        facility: ['Duke SMIF'],
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
      expect(subject.modality.first).to eq('MedicalXRayComputedTomography')
    end
    it "creates with correct facility" do
      expect(subject.facility.first).to eq('Duke SMIF')
    end
    it "creates with correct description" do
      expect(subject.description.first).to eq('A sample description')
    end
  end
end
