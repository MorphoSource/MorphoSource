# Generated via
#  `rails generate hyrax:work Organization`
require 'rails_helper'

RSpec.describe Hyrax::OrganizationForm do
	subject { Hyrax::OrganizationForm }

  it "has expected metadata terms" do
    expect(subject.terms).to include(:title, :organization_code, :description, :address, :city, :state_province, :country)
  end

  it "has expected required metadata terms" do
  	expect(subject.required_fields).to include(:title, :organization_code)
  end

  it "has expected single valued metadata terms" do
  	expect(subject.single_valued_fields).to include(:title, :organization_code, :description, :address, :city, :state_province, :country)
  end
end
