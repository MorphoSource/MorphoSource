# Generated via
#  `rails generate hyrax:work Device`
require 'rails_helper'

RSpec.describe Hyrax::DeviceForm do
  subject { Hyrax::DeviceForm }
  
  it "has expected metadata terms" do
    expect(subject.terms).to include(:title, :creator, :modality, :facility, :description)
  end

  it "has expected required metadata terms" do
  	expect(subject.required_fields).to include(:title, :creator, :modality)
  end
  
  it "has expected single valued metadata terms" do
  	expect(subject.single_valued_fields).to include(:title, :description)
  end
end
