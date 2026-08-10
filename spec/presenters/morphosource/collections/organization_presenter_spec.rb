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

  describe 'default manager filtering' do
    let(:default_manager) { FactoryBot.create(:contributor) }
    let(:manager)         { FactoryBot.create(:contributor) }

    before do
      allow(Morphosource).to receive(:default_organization_manager).and_return(default_manager.ms_id)
    end

    context 'when the organization has another manager besides the seeded one' do
      before { organization.managers_group.users << manager }

      it 'is seeded with the default manager, so there is something to filter' do
        expect(organization.managers).to match_array([default_manager, manager])
      end

      it 'shows only the real manager' do
        expected = %(<a href="/users/#{manager.ms_id}">#{manager.name_or_email}</a>)
        expect(subject.manager_links_for_display).to eq(expected)
      end
    end

    # The empty list this produces is what shared/collections/_managed_by and
    # include_empty: false on the about tab's collection managers row rely on.
    context 'when the seeded default manager is the only manager' do
      it 'renders no managers at all' do
        expect(organization.managers).to eq([default_manager])
        expect(subject.manager_links_for_display).to eq('')
      end
    end
  end
end