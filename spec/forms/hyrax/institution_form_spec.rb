# Generated via
#  `rails generate hyrax:work Institution`
require 'rails_helper'

RSpec.describe Hyrax::InstitutionForm do
	subject { Hyrax::InstitutionForm }

  it "has expected metadata terms" do
    expect(subject.terms).to include(:title, :institution_code, :description, :address, :city, :state_province, :country)
  end

  it "has expected required metadata terms" do
  	expect(subject.required_fields).to include(:title, :institution_code)
  end

  it "has expected single valued metadata terms" do
  	expect(subject.single_valued_fields).to include(:title, :institution_code, :description, :address, :city, :state_province, :country)
  end
end
