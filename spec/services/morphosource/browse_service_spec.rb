require 'rails_helper'

RSpec.describe Morphosource::BrowseService do

  subject { described_class.new }

  let(:public)      { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
  let(:ability) { double Ability }

  let!(:org1)  {
    Organization.create(
      title: ['title'],
      organization_type: ["foobar"]
    )
  }
  let!(:specimen) {
    BiologicalSpecimen.create(
      title: [ 'abc:123' ],
      catalog_number: [ '123' ],
      institution_code: [ 'INST1' ],
      collection_code: [ 'abc' ],
      vouchered: [ true ],
      organization_id: [org1.id]
    )
  }

  let!(:team_collection_type) { Hyrax::CollectionType.create(title: 'Team', machine_id: 88) }
  let!(:project_collection_type) { Hyrax::CollectionType.create(title: 'Project', machine_id: 77) }
  let!(:user) { User.create(display_name: 'John Doe', email: 'johndoe@email.com', password: 'password', ms_id: 'abc123') }
  let!(:team1) { Collection.create(title: ['Team_B'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id, visibility: public) }

  let(:project1) { Collection.create(title: ['Project_B'], collection_type_gid: project_collection_type.gid, depositor: user.ms_id, visibility: public) }
  let!(:media1) {
    Media.create( title: ["Test Media Work"],
                  media_type: ["xyz"]
                  )
  }
  let!(:device)           { Device.create(title: ['device'], modality: ['Photogrammetry']) }
  let!(:imagingEvent)     { ImagingEvent.create(title: ['imagingEvent'], depositor: user.ms_id, ie_modality: device.modality, device_id: [device.id], physical_object_id: [specimen.id]) }

  before do
    imagingEvent.ordered_members << media1
    imagingEvent.save
    media1.member_of_collections << team1
    media1.save
    project1.member_of_collections << team1
    project1.save
  end

  describe 'total_po_by_org(org_id)' do
    it 'returns total_po_by_org' do
      results = subject.total_po_by_org(org1.id)
      expect(results).to eq(1)
    end
  end

  describe 'total_media_by_org(org_id)' do
    it 'returns total_media_by_org' do
      results = subject.total_media_by_org(org1.id)
      expect(results).to eq(1)
    end
  end

  describe 'total_media_and_po_by_collection(collection_id)' do
    it 'returns media and po count by collection_id' do
      media_count, po_count = subject.total_media_and_po_by_collection(team1.id)
      expect(media_count).to eq(1)
      expect(po_count).to eq(1)
    end
  end

  describe 'total_team_projects_by_collection(collection_id)' do
    it 'returns team project count by collection_id' do
      results = subject.total_team_projects_by_collection(team1.id)
      expect(results).to eq(1)
    end
  end

  describe 'media_po_type_facets' do
    it 'returns media_po_type_facets, media count' do
      facets, total_media = subject.media_po_type_facets
      expect(facets["media_physical_object_type_ssim"]["Biological Specimen"]).to eq(1)
      expect(total_media).to eq(1)
    end
  end

  describe 'media_type_and_modality_facets' do
    it 'returns media_type_and_modality_facets, media count' do
      facets, total_media = subject.media_type_and_modality_facets
      expect(facets["media_type_sim"]["xyz"]).to eq(1)
      expect(facets["media_modality_ssim"][device.modality.first]).to eq(1)
      expect(total_media).to eq(1)
    end
  end

end
