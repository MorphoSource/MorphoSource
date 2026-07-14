require 'rails_helper'
require 'spec_helper'

RSpec.describe Morphosource::Collections::OrganizationCollectionsControllerBehavior do

  subject { Morphosource::Collections::OrganizationCollectionsController.new }

  describe 'media_objects_search_builder_class' do
    it { expect(subject.media_objects_search_builder_class).to eq(Morphosource::Collections::OrganizationCollections::MediaObjectsSearchBuilder) }
  end

  describe 'media_count_search_builder_class' do
    it { expect(subject.media_count_search_builder_class).to eq(Morphosource::Collections::OrganizationCollections::OrganizationMediaSearchBuilder) }
  end

  describe 'organization_device_count' do
    let(:depositor)     { FactoryBot.create(:contributor) }
    let!(:organization) { FactoryBot.create(:organization_collection, depositor: depositor.ms_id) }
    let(:device)        { FactoryBot.create(:device_resource) }
    let(:device2)       { FactoryBot.create(:device) }

    before do
      model_field = ActiveFedora.index_field_mapper.solr_name('has_model', :symbol)
      [
        [device.id.to_s, 'DeviceResource'],
        [device2.id.to_s, 'Device']
      ].each do |id, model_name|
        ActiveFedora::SolrService.add(
          {
            id: id,
            model_field => [model_name],
            'device_organization_id_ssim' => [organization.id]
          },
          softCommit: true
        )
      end
      ActiveFedora::SolrService.commit
      subject.instance_variable_set(:@collection, organization)
    end

    it 'returns the number of devices owned by the organization' do
      expect(subject.organization_device_count).to eq(2)
    end

    it 'queries by organization id and applies has_model as an fq filter' do
      solr_service = instance_double(Morphosource::SolrService)
      allow(Morphosource::SolrService).to receive(:new).and_return(solr_service)

      expect(solr_service).to receive(:get_count)
        .with("device_organization_id_ssim:#{organization.id}",
              fq: ["has_model_ssim:(Device OR DeviceResource)"])
        .and_return(2)

      expect(subject.organization_device_count).to eq(2)
    end
  end

  describe 'device_media_count' do
    let(:depositor)       { FactoryBot.create(:contributor) }
    let!(:organization)   { FactoryBot.create(:organization_collection, depositor: depositor.ms_id) }
    let(:specimen)        { FactoryBot.create(:biological_specimen) }
    let(:device)          { FactoryBot.create(:device_resource, modality: ['Photogrammetry'], organization_id: [organization.id]) }
    let(:device2)         { FactoryBot.create(:device_resource, modality: ['Photogrammetry'], organization_id: [organization.id]) }
    let(:media)           { FactoryBot.create(:public_media) }
    let(:media2)          { FactoryBot.create(:public_media) }

    before do
      ActiveFedora::SolrService.add(
        {
          id: media.id,
          'has_model_ssim' => ['Media'],
          'media_device_facility_organization_id_ssim' => [organization.id],
          'read_access_group_ssim' => ['public']
        },
        softCommit: true
      )
      ActiveFedora::SolrService.add(
        {
          id: media2.id,
          'has_model_ssim' => ['Media'],
          'media_device_facility_organization_id_ssim' => [organization.id],
          'read_access_group_ssim' => ['public']
        },
        softCommit: true
      )
      ActiveFedora::SolrService.commit
      subject.instance_variable_set(:@collection, organization)
      subject.instance_variable_set(:@current_user, depositor)
      sign_in depositor
    end

    it 'returns the number of media owned by the organization' do
      expect(subject.device_media_count).to eq(2)
    end
  end

  describe 'query_media_management_counts' do
    let(:depositor)     { FactoryBot.create(:contributor) }
    let!(:organization) { FactoryBot.create(:organization_collection, depositor: depositor.ms_id) }
    let(:other_owner)   { FactoryBot.create(:contributor) }

    let(:managed_media)           { FactoryBot.create(:media, title: ['managed']) }
    let(:transfer_pending_media)  { FactoryBot.create(:media, title: ['transfer pending']) }
    let(:awaiting_publish_media)  { FactoryBot.create(:media, title: ['awaiting publish']) }
    let(:no_transfer_media)       { FactoryBot.create(:media, title: ['no transfer']) }

    before do
      ActiveFedora::SolrService.add(
        {
          id: managed_media.id,
          'has_model_ssim' => ['Media'],
          'media_organization_id_ssim' => [organization.id],
          'owner_ssim' => [organization.id]
        },
        softCommit: true
      )
      ActiveFedora::SolrService.add(
        {
          id: transfer_pending_media.id,
          'has_model_ssim' => ['Media'],
          'media_organization_id_ssim' => [organization.id],
          'owner_ssim' => [other_owner.ms_id],
          'pending_org_transfer_bsi' => true
        },
        softCommit: true
      )
      ActiveFedora::SolrService.add(
        {
          id: awaiting_publish_media.id,
          'has_model_ssim' => ['Media'],
          'media_organization_id_ssim' => [organization.id],
          'owner_ssim' => [other_owner.ms_id],
          'organization_transfer_on_publish_bsi' => true
        },
        softCommit: true
      )
      ActiveFedora::SolrService.add(
        {
          id: no_transfer_media.id,
          'has_model_ssim' => ['Media'],
          'media_organization_id_ssim' => [organization.id],
          'owner_ssim' => [other_owner.ms_id]
        },
        softCommit: true
      )
      ActiveFedora::SolrService.commit
      subject.instance_variable_set(:@collection, organization)
      subject.query_media_management_counts
    end

    it 'sets the correct media management count variables' do
      expect(subject.instance_variable_get(:@managed_media_count)).to eq(1)
      expect(subject.instance_variable_get(:@unmanaged_media_transfer_pending_count)).to eq(1)
      expect(subject.instance_variable_get(:@unmanaged_media_awaiting_publish_count)).to eq(1)
      expect(subject.instance_variable_get(:@unmanaged_media_no_transfer_count)).to eq(1)
    end
  end

  describe 'query_collection_counts' do
    let(:depositor)       { FactoryBot.create(:contributor) }
    let!(:organization)   { FactoryBot.create(:organization_collection, depositor: depositor.ms_id) }
    let(:org_specimen)    { FactoryBot.create(:biological_specimen, organization_id: [organization.id]) }
    let(:org_cho)         { FactoryBot.create(:cultural_heritage_object, organization_id: [organization.id]) }
    let(:org_device)      { FactoryBot.create(:device_resource, modality: ['Photogrammetry'], organization_id: [organization.id]) }

    let(:outside_org)     { FactoryBot.create(:organization_collection, depositor: depositor.ms_id) }
    let(:outside_cho)     { FactoryBot.create(:cultural_heritage_object, organization_id: [outside_org.id]) }
    let(:outside_device)  { FactoryBot.create(:device_resource, modality: ['Photogrammetry'], organization_id: [outside_org.id]) }

    let(:media1)          { FactoryBot.create(:public_media, title: ['media1']) }
    let(:media2)          { FactoryBot.create(:public_media, title: ['media2']) }
    let(:media3)          { FactoryBot.create(:public_media, title: ['media3']) }
    let(:media4)          { FactoryBot.create(:public_media, title: ['media4']) }
    let(:media5)          { FactoryBot.create(:public_media, title: ['media5']) }
    let(:media)           { [media1, media2, media3, media4, media5] }

    before do
      model_field = ActiveFedora.index_field_mapper.solr_name('has_model', :symbol)
      ActiveFedora::SolrService.add(
        {
          id: org_device.id.to_s,
          model_field => ['DeviceResource'],
          'device_organization_id_ssim' => [organization.id]
        },
        softCommit: true
      )
      ActiveFedora::SolrService.add(
        {
          id: media1.id,
          'has_model_ssim' => ['Media'],
          'media_organization_id_ssim' => [organization.id],
          'media_device_facility_organization_id_ssim' => [organization.id],
          'physical_object_id_ssim' => [org_specimen.id],
          'read_access_group_ssim' => ['public']
        },
        softCommit: true
      )
      ActiveFedora::SolrService.add(
        {
          id: media2.id,
          'has_model_ssim' => ['Media'],
          'media_organization_id_ssim' => [organization.id],
          'media_device_facility_organization_id_ssim' => [organization.id],
          'physical_object_id_ssim' => [org_cho.id],
          'read_access_group_ssim' => ['public']
        },
        softCommit: true
      )
      ActiveFedora::SolrService.add(
        {
          id: media3.id,
          'has_model_ssim' => ['Media'],
          'media_device_facility_organization_id_ssim' => [organization.id],
          'physical_object_id_ssim' => [outside_cho.id],
          'read_access_group_ssim' => ['public']
        },
        softCommit: true
      )
      ActiveFedora::SolrService.add(
        {
          id: media4.id,
          'has_model_ssim' => ['Media'],
          'media_organization_id_ssim' => [organization.id],
          'physical_object_id_ssim' => [org_specimen.id],
          'read_access_group_ssim' => ['public']
        },
        softCommit: true
      )
      ActiveFedora::SolrService.add(
        {
          id: media5.id,
          'has_model_ssim' => ['Media'],
          'media_organization_id_ssim' => [organization.id],
          'physical_object_id_ssim' => [org_cho.id],
          'read_access_group_ssim' => ['public']
        },
        softCommit: true
      )
      ActiveFedora::SolrService.commit
      [org_specimen, org_cho, outside_cho].each(&:update_index)
      subject.instance_variable_set(:@collection, organization)
      subject.instance_variable_set(:@current_user, depositor)
      subject.instance_variable_set(:@object_ids, subject.send(:collection_object_ids))
      sign_in depositor
      subject.query_collection_counts
    end

    it 'sets the correct collection count variables' do
      expect(subject.instance_variable_get(:@media_count)).to eq(4)
      expect(subject.instance_variable_get(:@device_media_count)).to eq(3)
      expect(subject.instance_variable_get(:@specimen_count)).to eq(1)
      expect(subject.instance_variable_get(:@cho_count)).to eq(2)
      expect(subject.instance_variable_get(:@device_count)).to eq(1)
    end
  end
end
