# Generated via
#  `rails generate hyrax:work CulturalHeritageObject`
require 'rails_helper'

RSpec.describe CulturalHeritageObject do

  it_behaves_like 'a Morphosource work'

  describe 'metadata' do

    # attributes shared between chos and specimens
    it_behaves_like 'a work with physical object metadata'

    # attributes unique to chos
    it 'has cultural heritage object metadata' do
      expect(subject.attributes.keys).to include( "aat_attribute",
                                                  "aat_material",
                                                  "aat_type",
                                                  "cho_attribute",
                                                  "cho_type",
                                                  "material",
                                                  "short_title" )
    end
  end

  describe "valid work relationships" do

    it "has no valid parents" do
      expect(subject.valid_parent_concerns).to match_array([])
    end

    it "has ImagingEvent as valid child concern" do
      expect(subject.valid_child_concerns).to match_array([])
    end

  end

  describe "instance" do
    subject { CulturalHeritageObject.new({
        title: ['Test CulturalHeritageObject']
      })
    }

    describe "valid work relationships" do

      it "has no valid parents" do
        expect(subject.valid_parent_concerns).to match_array([])
      end

      it "has ImagingEvent as valid child concern" do
        expect(subject.valid_child_concerns).to match_array([])
      end

    end

  end

end
