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
      member_of_team_ids: ['id1','id2','id3'],
      member_of_project_ids: ['id1','id2','id3'],
      taxonomies_titles: ['taxonomy1', 'taxonomy2'],
    } }

    before do
      field_values.each do |k,v|
        allow(media).to receive(k).and_return(v)
      end
    end

    it 'indexes file_set_visibilities' do
      expect(subject['file_set_visibilities_ssim']).to eq field_values[:file_set_visibilities]
    end
    it 'indexes fileset_accessibility' do
      expect(subject['fileset_accessibility_ssim']).to eq field_values[:fileset_accessibility]
    end
    it 'indexes download_access_group' do
      expect(subject['download_access_group_ssim']).to match_array field_values[:download_groups]
    end
    it 'indexes download_access_person' do
      expect(subject['download_access_person_ssim']).to match_array field_values[:download_users]
    end
    it 'indexes human_readable_media_type' do
      expect(subject['human_readable_media_type_tesim']).to eq field_values[:human_readable_media_type]
      expect(subject['human_readable_media_type_ssim']).to eq field_values[:human_readable_media_type]
    end
    it 'indexes media_modality' do
      expect(subject['media_modality_tesim']).to eq field_values[:modality]
      expect(subject['media_modality_ssim']).to eq field_values[:modality]
    end
    it 'indexes public collection membership' do
      expect(subject['member_of_public_collection_ids_ssim']).to eq field_values[:member_of_public_collection_ids]
    end
    it 'indexes team ids' do
      expect(subject['member_of_team_ids_ssim']).to eq(field_values[:member_of_team_ids])
    end
    it 'indexes project ids' do
      expect(subject['member_of_project_ids_ssim']).to eq(field_values[:member_of_project_ids])
    end
    it 'indexes publication status' do
      expect(subject['publication_status_ssi']).to eq('Restricted Download')
    end
    it 'indexes linked team origin' do
      expect(subject['org_linked_team_origin_ssim']).to match_array(["Team Only", "Team"])
    end
  end

  describe 'imaging_event_id' do
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
    let(:device)                  { Device.create(title: ['device'], modality: ['Photogrammetry']) }
    let(:imaging_event)           { ImagingEvent.create(title: ['title'], device_id: [device.id], physical_object_id: [specimen.id], ie_modality: device.modality) }
    let!(:processing_event1)       { ProcessingEvent.create(title: ['processing_event']) }
    let!(:works)                  { [ imaging_event, processing_event1 ] }

    subject(:solr_document)       { described_class.new(media1).generate_solr_document }

    before do
      imaging_event.ordered_members << processing_event1
      processing_event1.ordered_members << media1
      works.each(&:save)
      works.each(&:reload)
    end

    it 'indexes related_media_ids' do
      expect(subject['imaging_event_id_tesim']).to include(imaging_event.id)
    end
  end

  describe 'physical object fields' do
    let(:organization)  { Organization.create(title: ['Organization']) }
    let(:taxonomy)      { Taxonomy.create(title: ['taxonomy title']) }
    let(:specimen)      { BiologicalSpecimen.create(title: ['Specimen'], vouchered: ['Yes'], organization_id: [organization.id], taxonomy_id: [taxonomy.id]) }
    let(:device)        { Device.create(title: ['device'], modality: ['Photogrammetry']) }
    let(:imaging_event) { ImagingEvent.create(title: ['Imaging Event'], device_id: [device.id], physical_object_id: [specimen.id], ie_modality: device.modality) }
    let(:works)         { [specimen, media, imaging_event] }

    before do
      imaging_event.ordered_members << media
      works.each(&:save)
      works.each(&:reload)
    end

    it 'indexes physical object id' do
      expect(subject['physical_object_id_ssim']).to match_array([specimen.id])
      expect(subject['physical_object_id_tesim']).to match_array([specimen.id])
    end

    it 'indexes physical object type' do
      expect(subject['media_physical_object_type_ssim']).to eq("Biological Specimen")
      expect(subject['media_physical_object_type_tesim']).to eq("Biological Specimen")
    end

    it 'indexes taxonomies' do
      expect(subject['taxonomy_tesim']).to match_array(taxonomy.title)
      expect(subject['taxonomy_ssim']).to match_array(taxonomy.title)
    end

    it 'indexes organizations' do
      expect(subject['media_organization_tesim']).to match_array([organization.title.first])
      expect(subject['media_organization_ssim']).to match_array([organization.title.first])
      expect(subject['media_organization_id_ssim']).to match_array([organization.id])
      expect(subject['media_organization_id_tesim']).to match_array([organization.id])
    end
  end

  describe 'publication status' do
    context 'media is open' do
      before do
        media.fileset_accessibility = ['open']
      end
      it 'is Open Download' do
        expect(subject['publication_status_ssi']).to eq('Open Download')
      end
    end
    context 'media is resticted download' do
      it 'is Restricted Download' do
        expect(subject['publication_status_ssi']).to eq('Restricted Download')
      end
    end
    context 'media is private' do
      before do
        media.fileset_accessibility = ['private']
      end
      it 'is Private' do
        expect(subject['publication_status_ssi']).to eq('Private')
      end
    end
  end

  describe 'organizations' do
    let(:org1)            { Organization.create(title: ['Organization1']) }
    let(:org2)            { Organization.create(title: ['Organization2']) }
    let(:specimen)        { BiologicalSpecimen.create(title: ['Specimen'], vouchered: ['Yes'], organization_id: [org1.id]) }
    let(:cho)             { CulturalHeritageObject.create(title: ['CulturalHeritageObject'], vouchered: ['Yes'], organization_id: [org2.id]) }
    let(:device)          { Device.create(title: ['Device'], modality: ['Photogrammetry']) }
    let(:imaging_event1)  { ImagingEvent.create(title: ['Imaging Event'], ie_modality: device.modality, device_id: [device.id], physical_object_id: [specimen.id]) }
    let(:imaging_event2)  { ImagingEvent.create(title: ['Imaging Event'], ie_modality: device.modality, device_id: [device.id], physical_object_id: [cho.id]) }
    let(:media)           { Media.create(title: ['Media']) }

    before do
      imaging_event1.ordered_members << media
      imaging_event2.ordered_members << media
      [imaging_event1, imaging_event2].each(&:save)
      media.reload
    end

    it 'returns all media organizations' do
      expect(MediaIndexer.new(media).organizations).to match_array([org1, org2])
    end
  end

  describe 'linked_team_origin' do
    let(:team_collection_type)  { Hyrax::CollectionType.create(title: 'Team') }
    let(:team)                  { Collection.create(title: ['team'], collection_type_gid: team_collection_type.gid) }
    let(:org)                   { Organization.create(title: ['Organization1']) }
    let(:specimen)              { BiologicalSpecimen.create(title: ['Specimen'], vouchered: ['Yes'], organization_id: [org.id]) }
    let(:device)                { Device.create(title: ['Device'], modality: ['Photogrammetry']) }
    let(:imaging_event)         { ImagingEvent.create(title: ['Imaging Event'], ie_modality: device.modality, device_id: [device.id], physical_object_id: [specimen.id]) }
    let(:media)                 { Media.create(title: ['Media']) }

    subject { MediaIndexer.new(media).linked_team_origin }

    before do
      imaging_event.ordered_members << media
      imaging_event.save
      media.reload
    end

    context 'media belongs to the team, not the linked organization' do
      before do
        media.member_of_collections << team
      end
      it { expect(subject).to match_array(['Team Only', 'Team']) }
    end
    context 'media belongs to the linked organization, not the team' do
      before do
        org.team_id = [team.id]
        org.save
      end
      it { expect(subject).to match_array(['Organization Only', 'Organization']) }
    end
    context 'media belongs to both the team and the linked organization' do
      before do
        org.team_id = [team.id]
        org.save
        media.member_of_collections << team
      end
      it { expect(subject).to match_array(['Team and Organization', 'Team', 'Organization']) }
    end
  end

  describe 'user_with_ownership' do
    let(:depositor) { User.create(email: 'depositor@email.com', password: 'password') }
    let(:owner)     { User.create(email: 'owner@email.com', password: 'password') }

    context 'media has an owner' do
      before do
        media.depositor = depositor.ms_id
        media.owner = owner.ms_id
        media.save
      end
      it { expect(subject['user_with_ownership_ssi']).to eq(owner.ms_id) }
    end
    context 'media does not have an owner' do
      before do
        media.depositor = depositor.ms_id
        media.save
      end
      it { expect(subject['user_with_ownership_ssi']).to eq(depositor.ms_id) }
    end
  end
 end
