# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Morphosource::PhysicalObjectIndexer do
  let(:specimen)                { BiologicalSpecimen.create(title: ['Specimen'], vouchered: ['Yes']) }
  let(:organization)            { Organization.create(title: ['Organization']) }
  let(:media)                   { Media.create(title: ['title'], media_type: ['Image'], keyword: ['red', 'blue', 'yellow'], visibility: 'open') }
  let(:device)                  { Device.create(title: ['device'], modality: ['Photogrammetry']) }
  let(:imaging_event)           { ImagingEvent.create(title: ['title'], device_id: [device.id], ie_modality: device.modality) }
  let(:project_collection_type) { Hyrax::CollectionType.create(title: 'Project', machine_id: 88) }
  let(:project)                 { Collection.create(title: ['Project'], collection_type_gid: project_collection_type.gid, depositor: 'msid', visibility: 'open') }
  let!(:works)                  { [organization, specimen, imaging_event, media] }

  subject(:solr_document)       { described_class.new(specimen).generate_solr_document }

  before do
    organization.ordered_members << specimen
    specimen.ordered_members << imaging_event
    imaging_event.ordered_members << media
    media.member_of_collections = [project]
    works.each(&:save)
    works.each(&:reload)
  end

  describe 'custom fields' do
    it 'indexes organization, media_type, media_collections, and media_keyword' do
      # organization
      expect(subject['organization_sim']).to eq(organization.title.to_a)
      expect(subject['organization_tesim']).to eq(organization.title.to_a)
      expect(subject['organization_id_ssim']).to eq([organization.id])
      # media_type
      expect(subject['public_media_type_tesim']).to eq(media.human_readable_media_type.to_a)
      expect(subject['public_media_type_ssim']).to eq(media.human_readable_media_type.to_a)
      # media_collections
      expect(subject['media_member_of_public_collection_ids_ssim']).to eq(media.member_of_public_collection_ids)
      # media_keyword
      expect(subject['public_media_keyword_tesim']).to match_array(media.keyword)
      expect(subject['public_media_keyword_ssim']).to match_array(media.keyword)

      expect(subject['related_media_ids_ssim']).to eq([media.id])
    end
  end
end
