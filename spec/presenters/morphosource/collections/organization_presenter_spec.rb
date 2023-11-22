require 'rails_helper'

RSpec.describe Morphosource::Collections::OrganizationPresenter do
  let(:depositor)     { FactoryBot.create(:contributor) }
  let(:organization)  { FactoryBot.create(:organization_collection, depositor: depositor.ms_id) }
  let(:solr_doc)      { double('solr doc', id: organization.id) }

  subject { described_class.new(solr_doc, double)}

  describe 'edit_path' do
    it { expect(subject.edit_path).to eq("/dashboard/organizations/#{organization.id}?locale=en") }
  end

  describe 'collection_type_title' do
    it { expect(subject.collection_type_title).to eq("Organization") }
  end
end