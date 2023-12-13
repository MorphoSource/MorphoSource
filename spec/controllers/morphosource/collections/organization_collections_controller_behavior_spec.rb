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
    let(:device)        { FactoryBot.create(:device) }
    let(:device2)       { FactoryBot.create(:device) }

    before do
      organization.ordered_members << device
      organization.ordered_members << device2
      organization.save!
      [device, device2].each(&:update_index)
      subject.instance_variable_set(:@collection, organization)
    end

    it 'returns the number of devices owned by the organization' do
      expect(subject.organization_device_count).to eq(2)
    end
  end

  describe 'device_media_count' do
    let(:depositor)       { FactoryBot.create(:contributor) }
    let!(:organization)   { FactoryBot.create(:organization_collection, depositor: depositor.ms_id) }
    let(:specimen)        { FactoryBot.create(:biological_specimen) }
    let(:device)          { FactoryBot.create(:device, modality: ['Photogrammetry']) }
    let(:device2)         { FactoryBot.create(:device, modality: ['Photogrammetry']) }
    let(:imaging_event)   { FactoryBot.create(:imaging_event, device_id: [device.id], ie_modality: device.modality, physical_object_id: [specimen.id]) }
    let(:imaging_event2)  { FactoryBot.create(:imaging_event, device_id: [device2.id], ie_modality: device2.modality, physical_object_id: [specimen.id]) }
    let(:media)           { FactoryBot.create(:public_media) }
    let(:media2)          { FactoryBot.create(:public_media) }

    before do
      organization.ordered_members << device
      organization.ordered_members << device2
      imaging_event.ordered_members << media
      imaging_event.ordered_members << media2
      [organization, imaging_event, imaging_event2].each(&:save!)
      [media, media2].each(&:update_index)
      subject.instance_variable_set(:@collection, organization)
      subject.instance_variable_set(:@current_user, depositor)
      sign_in depositor
    end

    it 'returns the number of media owned by the organization' do
      expect(subject.device_media_count).to eq(2)
    end
  end

  describe 'query_collection_counts' do
    let(:depositor)       { FactoryBot.create(:contributor) }
    let!(:organization)   { FactoryBot.create(:organization_collection, depositor: depositor.ms_id) }
    let(:org_specimen)    { FactoryBot.create(:biological_specimen, organization_id: [organization.id]) }
    let(:org_cho)         { FactoryBot.create(:cultural_heritage_object, organization_id: [organization.id]) }
    let(:org_device)      { FactoryBot.create(:device, modality: ['Photogrammetry']) }

    let(:outside_org)     { FactoryBot.create(:organization_collection, depositor: depositor.ms_id) }
    let(:outside_cho)     { FactoryBot.create(:cultural_heritage_object, organization_id: [outside_org.id]) }
    let(:outside_device)  { FactoryBot.create(:device, modality: ['Photogrammetry']) }

    # linked through organization specimen and device
    let(:imaging_event1)  { FactoryBot.create(:imaging_event, device_id: [org_device.id], ie_modality: org_device.modality, physical_object_id: [org_specimen.id]) }
    # linked through organization cho and device
    let(:imaging_event2)  { FactoryBot.create(:imaging_event, device_id: [org_device.id], ie_modality: org_device.modality, physical_object_id: [org_cho.id]) }
    # linked through organization specimen
    let(:imaging_event3)  { FactoryBot.create(:imaging_event, device_id: [outside_device.id], ie_modality: outside_device.modality, physical_object_id: [org_specimen.id]) }
    # linked through organization cho
    let(:imaging_event4)  { FactoryBot.create(:imaging_event, device_id: [outside_device.id], ie_modality: outside_device.modality, physical_object_id: [org_cho.id]) }
    # linked through organization device
    let(:imaging_event5)  { FactoryBot.create(:imaging_event, device_id: [org_device.id], ie_modality: org_device.modality, physical_object_id: [outside_cho.id]) }
    let(:imaging_events)  { [imaging_event1, imaging_event2, imaging_event3, imaging_event4, imaging_event5] }

    let(:media1)          { FactoryBot.create(:public_media, title: ['media1']) }
    let(:media2)          { FactoryBot.create(:public_media, title: ['media2']) }
    let(:media3)          { FactoryBot.create(:public_media, title: ['media3']) }
    let(:media4)          { FactoryBot.create(:public_media, title: ['media4']) }
    let(:media5)          { FactoryBot.create(:public_media, title: ['media5']) }
    let(:media)           { [media1, media2, media3, media4, media5] }

    before do
      organization.ordered_members << org_device
      organization.save!
      org_device.update_index
      imaging_event1.ordered_members << media1
      imaging_event2.ordered_members << media2
      imaging_event3.ordered_members << media3
      imaging_event4.ordered_members << media4
      imaging_event5.ordered_members << media5
      imaging_events.each(&:save!)
      media.each(&:update_index)
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