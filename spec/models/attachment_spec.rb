# Generated via
#  `rails generate hyrax:work Attachment`
require 'rails_helper'

RSpec.describe Attachment do
  it_behaves_like 'a Morphosource work'

  describe "metadata attributes" do
    it "include the appropriate terms" do
      expect(subject.attributes).to include('title')
    end
  end

  describe "valid work relationships" do

    it "has all other work types as valid parents" do
      expect(subject.valid_parent_concerns).to match_array([Media, Organization, Device, ProcessingEvent, BiologicalSpecimen, CulturalHeritageObject, ImagingEvent])
    end
    it "has no valid children" do
      expect(subject.valid_child_concerns).to match_array([])
    end
  end

  describe "instance" do
    subject { Attachment.new({
        title: ['Test Attachment']
      })
    }

    it "creates with correct title" do
      expect(subject.title.first).to eq('Test Attachment')
    end

    describe "valid work relationships" do

      it "has all other work types as valid parents" do
        expect(subject.valid_parent_concerns).to match_array([Media, Organization, Device, ProcessingEvent, BiologicalSpecimen, CulturalHeritageObject, ImagingEvent])
      end

      it "has no valid children" do
        expect(subject.valid_child_concerns).to match_array([])
      end

    end

  end

end
