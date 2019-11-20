# Generated via
#  `rails generate hyrax:work Organization`
require 'rails_helper'

RSpec.describe Organization do

  it_behaves_like 'a Morphosource work'

  describe "metadata attributes" do
    it "include the appropriate terms" do
      expect(subject.attributes).to include('title', 'institution_code', 'description', 'address', 'city', 'state_province', 'country')
    end
  end

  describe "valid work relationships" do
    it "has no valid parents" do
      expect(subject.valid_parent_concerns).to match_array([])
    end

    it "has Device, BiologicalSpecimen, CulturalHeritageObject, and Attachment as valid children" do
      expect(subject.valid_child_concerns).to match_array([Device, BiologicalSpecimen, CulturalHeritageObject, Attachment])
    end
  end

  describe "instance" do
    subject { Organization.new({
        title: ['American Museum of Natural History'],
        institution_code: ['AMNH'],
        description: ['A sample description'],
        address: ['Central Park West'],
        city: ['New York City'],
        state_province: ['New York'],
        country: ['United States']
      })
    }

    it "creates with correct title" do
      expect(subject.title.first).to eq('American Museum of Natural History')
    end

    it "creates with correct institution_code" do
      expect(subject.institution_code.first).to eq('AMNH')
    end

    it "creates with correct description" do
      expect(subject.description.first).to eq('A sample description')
    end

    it "creates with correct address" do
      expect(subject.address.first).to eq('Central Park West')
    end

    it "creates with correct city" do
      expect(subject.city.first).to eq('New York City')
    end

    it "creates with correct state_province" do
      expect(subject.state_province.first).to eq('New York')
    end

    it "creates with correct country" do
      expect(subject.country.first).to eq('United States')
    end

    describe "valid work relationships" do

      it "has no valid parents" do
        expect(subject.valid_parent_concerns).to match_array([])
      end

      it "has Device, BiologicalSpecimen, CulturalHeritageObject, and Attachment as valid children" do
        expect(subject.valid_child_concerns).to match_array([Device, BiologicalSpecimen, CulturalHeritageObject, Attachment])
      end

    end

  end

end
