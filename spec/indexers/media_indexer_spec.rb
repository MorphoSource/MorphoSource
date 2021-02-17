require 'rails_helper'

RSpec.describe MediaIndexer do

  it 'uses MediaThumbnailPathService' do
    expect(described_class.thumbnail_path_service).to be(Morphosource::MediaThumbnailPathService)
  end

  subject(:solr_document) { MediaIndexer.new(media).generate_solr_document }
  let(:media)             { Media.create(title: ['New Media'], fileset_accessibility: ['restricted_download']) }

  describe 'custom fields' do
    let(:field_values) { {
      fileset_accessibility: media.fileset_accessibility,
      file_set_visibilities: ['restricted'],
      download_groups: ['download_group1', 'download_group2'],
      download_users: ['download_user1', 'download_user2'],
      human_readable_media_type: 'Image',
      modality: "Scanning Electron Microscopy",
      physical_object_type: "Cultural Heritage Object",
      organization_titles: ["Organization 1", "Organization 2"],
      organization_id: ["org123"],
      member_of_public_collection_ids: ['id1','id2','id3'],
      taxonomies_titles: ['taxonomy1', 'taxonomy2'],
      related_media_ids: ['mid1','mid2','mid3']
    } }

    before do
      field_values.each do |k,v|
        allow(media).to receive(k).and_return(v)
      end
    end

    it 'indexes file_set_visibilities' do
      expect(subject['file_set_visibilities_ssim']).to eq field_values[:file_set_visibilities]
    end
    it 'indexes download_access_group' do
      expect(subject['download_access_group_ssim']).to match_array field_values[:download_groups]
    end
    it 'indexes download_access_person' do
      expect(subject['download_access_person_ssim']).to match_array field_values[:download_users]
    end
    it 'indexes fileset_accessibility' do
      expect(subject['fileset_accessibility_ssim']).to eq field_values[:fileset_accessibility]
    end
    it 'indexes human_readable_media_type' do
      expect(subject['human_readable_media_type_tesim']).to eq field_values[:human_readable_media_type]
      expect(subject['human_readable_media_type_sim']).to eq field_values[:human_readable_media_type]
    end
    it 'indexes media_modality' do
      expect(subject['media_modality_tesim']).to eq field_values[:modality]
      expect(subject['media_modality_sim']).to eq field_values[:modality]
    end
    it 'indexes public collection membership' do
      expect(subject['member_of_public_collection_ids_ssim']).to eq field_values[:member_of_public_collection_ids]
    end
    it 'indexes related media ids' do
      expect(subject['related_media_ids_ssim']).to eq field_values[:related_media_ids]
    end
  end

  describe 'related_media_ids' do
    #- Specimen1
    #
    #  - IE1
    #
    #    - PE1
    #      - Media1
    #
    #    - PE2
    #      - Media2
    let(:specimen)                { BiologicalSpecimen.create(title: ['Specimen'], vouchered: ['Yes']) }
    let(:media1)                   { Media.create(title: ['title'], media_type: ['Image'], keyword: ['red', 'blue', 'yellow'], visibility: 'open') }
    let(:media2)                   { Media.create(title: ['title'], media_type: ['Image'], keyword: ['red', 'blue', 'yellow'], visibility: 'open') }
    let(:device)                  { Device.create(title: ['device'], modality: ['Photogrammetry']) }
    let(:imaging_event)           { ImagingEvent.create(title: ['title'], device_id: [device.id], physical_object_id: [specimen.id], ie_modality: device.modality) }
    let!(:processing_event1)       { ProcessingEvent.create(title: ['processing_event']) }
    let!(:processing_event2)       { ProcessingEvent.create(title: ['processing_event']) }
    let!(:works)                  { [ imaging_event, processing_event1, processing_event2 ] }

    subject(:solr_document)       { described_class.new(media1).generate_solr_document }

    before do
      imaging_event.ordered_members << processing_event1
      imaging_event.ordered_members << processing_event2
      processing_event1.ordered_members << media1
      processing_event2.ordered_members << media2
      works.each(&:save)
      works.each(&:reload)
    end

    it 'indexes related_media_ids' do
      expect(subject['related_media_ids_ssim']).to include(media1.id, media2.id)
    end
  end

  describe 'physical object fields' do
    let(:organization)  { Organization.create(title: ['Organization']) }
    let(:taxonomy)      { Taxonomy.create(title: ['taxonomy title']) }
    let(:specimen)      { BiologicalSpecimen.create(title: ['Specimen'], vouchered: ['Yes'], organization_id: [organization.id], taxonomy_id: [taxonomy.id]) }
    let(:cho)           { CulturalHeritageObject.create(title: ['CHO'], vouchered: ['Yes'], organization_id: [organization.id]) }
    let(:device)        { Device.create(title: ['device'], modality: ['Photogrammetry']) }
    let(:imaging_event) { ImagingEvent.create(title: ['Imaging Event'], device_id: [device.id], physical_object_id: [cho.id, specimen.id], ie_modality: device.modality) }
    let(:works)         { [specimen, cho, media, imaging_event] }

    before do
      imaging_event.ordered_members << media
      works.each(&:save)
      works.each(&:reload)
    end

    it 'indexes physical object type' do
      expect(subject['media_physical_object_type_tesim']).to eq('Biological Specimen')
      expect(subject['media_physical_object_type_sim']).to eq('Biological Specimen')
    end

    it 'indexes physical object id' do
      expect(subject['physical_object_id_ssim']).to match_array([specimen.id, cho.id])
      expect(subject['physical_object_id_tesim']).to match_array([specimen.id, cho.id])
    end

    it 'indexes taxonomies' do
      expect(subject['taxonomy_tesim']).to match_array(taxonomy.title)
      expect(subject['taxonomy_ssim']).to match_array(taxonomy.title)
    end
  end
end
