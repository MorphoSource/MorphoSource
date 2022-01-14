# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Morphosource::PhysicalObjectIndexer do
  let(:organization)            { Organization.create(title: ['Organization']) }
  let(:specimen)                { BiologicalSpecimen.create(title: ['Specimen'], vouchered: ['Yes'], organization_id: [organization.id]) }
  let(:media)                   { Media.create(title: ['title'], media_type: ['Image'], keyword: ['red', 'blue', 'yellow'], visibility: 'open') }
  let(:device)                  { Device.create(title: ['device'], modality: ['Photogrammetry']) }
  let(:imaging_event)           { ImagingEvent.create(title: ['title'], device_id: [device.id], physical_object_id: [specimen.id], ie_modality: device.modality) }
  let(:project_collection_type) { Hyrax::CollectionType.create(title: 'Project') }
  let(:project)                 { Collection.create(title: ['Project'], collection_type_gid: project_collection_type.gid, depositor: 'msid', visibility: 'open') }
  let(:team_collection_type)    { Hyrax::CollectionType.create(title: 'Team') }
  let(:team)                    { Collection.create(title: ['Team'], collection_type_gid: team_collection_type.gid, depositor: 'msid', visibility: 'open') }
  let!(:works)                  { [imaging_event, media] }

  subject(:solr_document)       { described_class.new(specimen).generate_solr_document }

  before do
    imaging_event.ordered_members << media
    media.member_of_collections = [project,team]
    works.each(&:save)
    works.each(&:reload)
  end

  describe 'custom fields' do
    it 'indexes organization, media_type, media_collections, and media_keyword' do
      # organization
      expect(subject['organization_tesim']).to eq(organization.title.to_a)
      expect(subject['organization_ssim']).to eq(organization.title.to_a)
      expect(subject['organization_id_ssim']).to eq([organization.id])
      # media_type
      expect(subject['public_media_type_tesim']).to eq(media.human_readable_media_type.to_a)
      expect(subject['public_media_type_ssim']).to eq(media.human_readable_media_type.to_a)
      # media_collections
      expect(subject['media_member_of_public_collection_ids_ssim']).to eq(media.member_of_public_collection_ids)
      expect(subject['media_member_of_project_ids_ssim']).to eq([project.id])
      expect(subject['media_member_of_team_ids_ssim']).to eq([team.id])
      # media_keyword
      expect(subject['public_media_keyword_tesim']).to match_array(media.keyword)
      expect(subject['public_media_keyword_ssim']).to match_array(media.keyword)

      expect(subject['related_media_ids_ssim']).to eq([media.id])
    end
  end
end
