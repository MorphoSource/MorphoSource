# Generated via
#  `rails generate hyrax:work CulturalHeritageObject`
require 'rails_helper'

RSpec.describe CulturalHeritageObject do

  it_behaves_like 'a Morphosource work'

  describe 'metadata' do

    it_behaves_like 'a work with physical object metadata'

    it 'has cultural heritage object metadata' do
      expect(subject.attributes.keys).to include('cho_type', 'material', 'short_title')
    end

  end

  describe "valid work relationships" do

    it "has only Organization as a valid parent" do
      expect(subject.valid_parent_concerns).to match_array([Organization])
    end

    it "has ImagingEvent and Attachment as valid child concerns" do
      expect(subject.valid_child_concerns).to match_array([ImagingEvent, Attachment])
    end

  end

  describe "instance" do
    subject { CulturalHeritageObject.new({
        title: ['Test CulturalHeritageObject']
      })
    }

    describe "valid work relationships" do

      it "has only Organization as a valid parent" do
        expect(subject.valid_parent_concerns).to match_array([Organization])
      end

      it "has ImagingEvent and Attachment as valid child concerns" do
        expect(subject.valid_child_concerns).to match_array([ImagingEvent, Attachment])
      end

    end

  end

end
