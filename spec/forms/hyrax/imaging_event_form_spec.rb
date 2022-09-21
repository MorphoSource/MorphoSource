# Generated via
#  `rails generate hyrax:work Device`
require 'rails_helper'

RSpec.describe Hyrax::ImagingEventForm do
  subject { Hyrax::ImagingEventForm }

  it "has expected metadata terms" do
    expect(subject.terms).to include(:slide_type)
  end

  it "has expected single valued metadata terms" do
    expect(subject.single_valued_fields).to include(:slide_type)
  end
end
