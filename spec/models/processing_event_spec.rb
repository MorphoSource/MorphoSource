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

    it "has Media and Attachment as valid children" do
      expect(subject.valid_child_concerns).to match_array([Media, Attachment])
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

      it "has Media and Attachment as valid children" do
        expect(subject.valid_child_concerns).to match_array([Media, Attachment])
      end

    end

  end

end
