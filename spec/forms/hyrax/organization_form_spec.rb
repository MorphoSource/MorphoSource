# Generated via
#  `rails generate hyrax:work Organization`
require 'rails_helper'

RSpec.describe Hyrax::OrganizationForm do
  subject { Hyrax::OrganizationForm }

  let(:terms) {
    [:organization_type,
    :institution_name,
    :title,
    :institution_code,
    :collection_code,
    :recordset_id,
    :related_url,
    :address,
    :city,
    :state_province,
    :country,
    :contact_person,
    :description,
    :download_permission,
    :download_reviewer,
    :agreement_uri,
    :license,
    :rights_statement,
    :permits_commercial_use,
    :permits_3d_use,
    :rights_holder,
    :funding,
    :publisher,
    :cite_as,
    :morphosource_use_agreement_type,
    :required_archival_of_published_derivatives,
    :preview_mode] }

  let(:required_fields)           { [:organization_type, :institution_name, :title, :institution_code] }

  let(:single_valued_fields)      { [:organization_type, :title, :description, :address, :city, :state_province, :country, :institution_name, :cite_as, :download_permission, :download_reviewer, :agreement_uri, :rights_statement, :permits_commercial_use, :permits_3d_use, :cite_as, :morphosource_use_agreement_type, :preview_mode] }

  let(:media_permissions_fields)  { [:download_permission, :download_reviewer, :agreement_uri, :license, :rights_statement, :permits_commercial_use, :permits_3d_use, :rights_holder, :funding, :publisher, :cite_as, :morphosource_use_agreement_type, :required_archival_of_published_derivatives, :preview_mode] }

  let(:secondary_terms)           { [:description, :related_url, :address, :city, :state_province, :country, :contact_person, :collection_code, :recordset_id] }

  it "has expected metadata terms" do
    terms.each do |term|
      expect(subject.terms).to include(term)
    end
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
