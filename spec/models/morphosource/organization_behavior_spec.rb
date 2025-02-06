# frozen_string_literal= true
require 'rails_helper'
RSpec.describe Organization, type: :model do
  let(:another_org)   { FactoryBot.create(:organization) }
  let(:organization)  { FactoryBot.create(:organization) }

  # returns media and objects associated with the organization through the organization's devices
  describe 'device_cultural_heritage_objects, device_media, device_physical_objects, device_specimens' do
    let(:specimen)        { FactoryBot.create(:biological_specimen, organization_id: [another_org.id]) }
    let(:cho)             { FactoryBot.create(:cultural_heritage_object, organization_id: [another_org.id]) }
    let(:deviceA)         { FactoryBot.create(:device, organization_id: [organization.id]) }
    let(:deviceB)         { FactoryBot.create(:device, organization_id: [organization.id]) }
    let(:imaging_eventA)  { FactoryBot.create(:imaging_event, device_id: [deviceA.id], ie_modality: deviceA.modality, physical_object_id: [cho.id]) }
    let(:imaging_eventB)  { FactoryBot.create(:imaging_event, device_id: [deviceB.id], ie_modality: deviceB.modality, physical_object_id: [specimen.id]) }
    let(:mediaA)          { FactoryBot.create(:media) }
    let(:mediaB)          { FactoryBot.create(:media) }

    before do
      imaging_eventA.ordered_members << mediaA
      imaging_eventB.ordered_members << mediaB
      [imaging_eventA, imaging_eventB].each(&:save!)
      [mediaA, mediaB].each(&:save!)
    end

    it 'returns the correct records' do
      # device_cultural_heritage_objects
      expect(organization.device_cultural_heritage_objects).to eq([cho])
      # device_media
      expect(organization.device_media).to eq([mediaA, mediaB])
      # device_physical_objects
      expect(organization.device_physical_objects).to match_array([specimen, cho])
      # device_specimens
      expect(organization.device_specimens).to eq([specimen])
    end
  end

  # returns media and objects associated with the organization
  describe 'cultural_heritage_objects, media, physical_objects, specimens' do
    let(:specimen)        { FactoryBot.create(:biological_specimen, organization_id: [organization.id]) }
    let(:cho)             { FactoryBot.create(:cultural_heritage_object, organization_id: [organization.id]) }
    let(:deviceA)         { FactoryBot.create(:device, organization_id: [organization.id]) }
    let(:deviceB)         { FactoryBot.create(:device, organization_id: [organization.id]) }
    let(:imaging_eventA)  { FactoryBot.create(:imaging_event, device_id: [deviceA.id], ie_modality: deviceA.modality, physical_object_id: [cho.id]) }
    let(:imaging_eventB)  { FactoryBot.create(:imaging_event, device_id: [deviceB.id], ie_modality: deviceB.modality, physical_object_id: [specimen.id]) }
    let(:mediaA)          { FactoryBot.create(:media) }
    let(:mediaB)          { FactoryBot.create(:media) }

    before do
      imaging_eventA.ordered_members << mediaA
      imaging_eventB.ordered_members << mediaB
      [imaging_eventA, imaging_eventB].each(&:save!)
      [mediaA, mediaB].each(&:save!)
    end

    it 'returns the correct records' do
      # cultural_heritage_objects
      expect(organization.cultural_heritage_objects).to eq([cho])
      # media
      expect(organization.media).to match_array([mediaA, mediaB])
      # physical_objects
      expect(organization.physical_objects).to match_array([specimen, cho])
      # specimens
      expect(organization.specimens).to eq([specimen])
    end
  end
end

RSpec.describe OrganizationCollection, type: :model do
  let(:another_org)   { FactoryBot.create(:organization_collection) }
  let(:organization)  { FactoryBot.create(:organization_collection) }

  # returns media and objects associated with the organization through the organization's devices
  describe 'device_cultural_heritage_objects, device_media, device_physical_objects, device_specimens' do
    let(:specimen)        { FactoryBot.create(:biological_specimen, organization_id: [another_org.id]) }
    let(:cho)             { FactoryBot.create(:cultural_heritage_object, organization_id: [another_org.id]) }
    let(:deviceA)         { FactoryBot.create(:device, organization_id: [organization.id]) }
    let(:deviceB)         { FactoryBot.create(:device, organization_id: [organization.id]) }
    let(:imaging_eventA)  { FactoryBot.create(:imaging_event, device_id: [deviceA.id], ie_modality: deviceA.modality, physical_object_id: [cho.id]) }
    let(:imaging_eventB)  { FactoryBot.create(:imaging_event, device_id: [deviceB.id], ie_modality: deviceB.modality, physical_object_id: [specimen.id]) }
    let(:mediaA)          { FactoryBot.create(:media) }
    let(:mediaB)          { FactoryBot.create(:media) }

    before do
      imaging_eventA.ordered_members << mediaA
      imaging_eventB.ordered_members << mediaB
      [imaging_eventA, imaging_eventB].each(&:save!)
      [mediaA, mediaB].each(&:save!)
    end

    it 'returns the correct records' do
      # device_cultural_heritage_objects
      expect(organization.device_cultural_heritage_objects).to eq([cho])
      # device_media
      expect(organization.device_media).to eq([mediaA, mediaB])
      # device_physical_objects
      expect(organization.device_physical_objects).to match_array([specimen, cho])
      # device_specimens
      expect(organization.device_specimens).to eq([specimen])
    end
  end

  # returns media and objects associated with the organization
  describe 'cultural_heritage_objects, media, physical_objects, specimens' do
    let(:specimen)                  { FactoryBot.create(:biological_specimen, organization_id: [organization.id]) }
    let(:cho)  { FactoryBot.create(:cultural_heritage_object, organization_id: [organization.id]) }
    let(:deviceA)                   { FactoryBot.create(:device, organization_id: [organization.id]) }
    let(:deviceB)                   { FactoryBot.create(:device, organization_id: [organization.id]) }
    let(:imaging_eventA)            { FactoryBot.create(:imaging_event, device_id: [deviceA.id], ie_modality: deviceA.modality, physical_object_id: [cho.id]) }
    let(:imaging_eventB)            { FactoryBot.create(:imaging_event, device_id: [deviceB.id], ie_modality: deviceB.modality, physical_object_id: [specimen.id]) }
    let(:mediaA)                    { FactoryBot.create(:media) }
    let(:mediaB)                    { FactoryBot.create(:media) }

    before do
      imaging_eventA.ordered_members << mediaA
      imaging_eventB.ordered_members << mediaB
      [imaging_eventA, imaging_eventB].each(&:save!)
      [mediaA, mediaB].each(&:save!)
    end

    it 'returns the correct records' do
      # cultural_heritage_objects
      expect(organization.cultural_heritage_objects).to eq([cho])
      # media
      expect(organization.media).to match_array([mediaA, mediaB])
      # physical_objects
      expect(organization.physical_objects).to match_array([specimen, cho])
      # specimens
      expect(organization.specimens).to eq([specimen])
    end
  end
end