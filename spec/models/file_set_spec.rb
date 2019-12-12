# Generated via
#  `rails generate hyrax:work Device`
require 'rails_helper'

RSpec.describe FileSet do

  describe "metadata attributes" do

    it "includes accessibility" do
      expect(subject.attributes).to include('accessibility')
    end
  end

  describe "instance" do
    subject { FileSet.new({accessibility: ['preview']})}

    it "creates with correct accessibility" do
      expect(subject.accessibility.first).to eq('preview')
    end
  end
end
