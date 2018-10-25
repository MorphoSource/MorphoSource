# Generated via
#  `rails generate hyrax:work Attachment`
require 'rails_helper'

RSpec.describe Hyrax::AttachmentForm do
  subject { Hyrax::AttachmentForm }
  
  it "has expected metadata terms" do
    expect(subject.terms).to include(:title)
  end
   it "has expected required metadata terms" do
  	expect(subject.required_fields).to include(:title)
  end
  
  it "has expected single valued metadata terms" do
  	expect(subject.single_valued_fields).to include(:title)
  end
end
