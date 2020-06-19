# Generated via
#  `rails generate hyrax:work Organization`
require 'rails_helper'

RSpec.describe Hyrax::OrganizationForm do
  subject { Hyrax::OrganizationForm }

  let(:terms)                     { [:organization_type, :institution_name, :title, :institution_code, :address, :city, :state_province, :country, :contact_person, :collection_code, :description, :download_permission, :download_reviewer, :agreement_uri, :license, :rights_statement, :terms_of_use, :permits_commercial_use, :permits_3d_use, :rights_holder, :funding, :publisher, :cite_as] }

  let(:required_fields)           { [:organization_type, :institution_name, :title, :institution_code] }

  let(:single_valued_fields)      { [:organization_type, :institution_name, :title, :description, :address, :city, :state_province, :country, :terms_of_use, :cite_as] }

  let(:media_permissions_fields)  { [:download_permission, :download_reviewer, :agreement_uri, :license, :rights_statement, :terms_of_use, :permits_commercial_use, :permits_3d_use, :rights_holder, :funding, :publisher, :cite_as] }

  let(:secondary_terms)           { [:description, :address, :city, :state_province, :country, :contact_person, :collection_code] }

  it "has expected metadata terms" do
    expect(subject.terms).to match_array(terms)
  end

  it "has expected required metadata terms" do
    expect(subject.required_fields).to match_array(required_fields)
  end

  it "has expected single valued metadata terms" do
    expect(subject.single_valued_fields).to match_array(single_valued_fields)
  end

  it 'has expected media permissions terms' do
    expect(subject.media_permissions_fields).to match_array(media_permissions_fields)
  end

  describe '#secondary_terms' do
    subject { described_class.new(Organization.new, nil, nil) }
    it 'has expected terms' do
      expect(subject.secondary_terms).to match_array(secondary_terms)
    end
  end
end
