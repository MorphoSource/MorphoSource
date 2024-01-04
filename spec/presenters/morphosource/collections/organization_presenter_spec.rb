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

  describe 'object_media_count' do
    let!(:media_doc) { FactoryBot.create(:public_media_document) }

    before do
      ActiveFedora::SolrService.add( { 'id' => media_doc['id'],
                                        'media_organization_id_ssim': { 'set'  => [organization.id] }
                                        }, softCommit: true )
    end

    it { expect(subject.object_media_count).to eq(1) }
  end

  describe 'device_media_count' do
    let!(:media_doc) { FactoryBot.create(:public_media_document) }

    before do
      ActiveFedora::SolrService.add( { 'id' => media_doc['id'],
                                        'media_device_facility_organization_id_ssim': { 'set'  => [organization.id] }
                                        }, softCommit: true )
    end

    it { expect(subject.device_media_count).to eq(1) }
  end
end