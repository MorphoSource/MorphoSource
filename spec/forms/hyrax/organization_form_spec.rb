# Generated via
#  `rails generate hyrax:work Organization`
require 'rails_helper'

RSpec.describe Hyrax::OrganizationForm do
  subject { Hyrax::OrganizationForm }

  let(:terms)                     { [:title, :creator, :contributor, :description, :keyword, :license, :rights_statement, :publisher, :date_created, :subject, :language, :identifier, :based_near, :related_url, :representative_id, :thumbnail_id, :rendering_ids, :files, :visibility_during_embargo, :embargo_release_date, :visibility_after_embargo, :visibility_during_lease, :lease_expiration_date, :visibility_after_lease, :visibility, :ordered_member_ids, :source, :in_works_ids, :member_of_collection_ids, :admin_set_id, :institution_code, :address, :city, :state_province, :country, :institution_name, :collection_code, :download_permission, :download_reviewer, :agreement_uri, :terms_of_use, :usage_agreement, :permits_commercial_use, :permits_3d_use, :rights_holder, :funding, :cite_as] }

  let(:required_fields)           { [:title, :institution_code] }

  let(:single_valued_fields)      { [:title, :institution_code, :description, :address, :city, :state_province, :country, :institution_name, :terms_of_use, :cite_as] }

  let(:media_permissions_fields)  { [:download_permission, :download_reviewer, :agreement_uri, :license, :rights_statement, :terms_of_use, :permits_commercial_use, :permits_3d_use, :rights_holder, :funding, :publisher, :cite_as] }

  let(:secondary_terms)           { [:creator, :contributor, :description, :keyword, :date_created, :subject, :language, :identifier, :based_near, :related_url, :source, :address, :city, :state_province, :country, :institution_name, :collection_code, :usage_agreement] }

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
