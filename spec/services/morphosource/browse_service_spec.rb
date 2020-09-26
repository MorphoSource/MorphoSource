require 'rails_helper'

RSpec.describe Morphosource::BrowseService do

  subject { described_class.new }

  let(:public)      { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
  let(:ability) { double Ability }

  let!(:biospecs) do
    [
        BiologicalSpecimen.create(title: [ 'abc:123' ],
                                  catalog_number: [ '123' ],
                                  institution_code: [ 'INST1' ],
                                  collection_code: [ 'abc' ],
                                  vouchered: [ true ]),
        BiologicalSpecimen.create(title: [ 'abc:456' ],
                                  catalog_number: [ '456' ],
                                  institution_code: [ 'INST2' ],
                                  collection_code: [ 'abc' ],
                                  vouchered: [ true ]),
    ]
  end

  let!(:team_collection_type) { Hyrax::CollectionType.create(title: 'Team', machine_id: 88) }
  let!(:project_collection_type) { Hyrax::CollectionType.create(title: 'Project', machine_id: 77) }
  let!(:user) { User.create(display_name: 'John Doe', email: 'johndoe@email.com', password: 'password', ms_id: 'abc123') }
  let!(:team1) { Collection.create(title: ['Team_B'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id, visibility: public) }

  let(:project1) { Collection.create(title: ['Project_B'], collection_type_gid: project_collection_type.gid, depositor: user.ms_id, visibility: public) }
  let!(:media1) { 
    Media.create( title: ["Test Media Work"],
                  physical_object_id: [biospecs.first.id],
                  media_type: ["xyz"]
                  ) 
  }
  let!(:imagingEvent)     { ImagingEvent.create(title: ['imagingEvent'], depositor: user.ms_id, ie_modality: ['modality abc']) }


  let!(:org1)  { 
    Organization.create(
      title: ['title'], 
      organization_type: ["foobar"]
    ) 
  }

  before do
    org1.ordered_members << biospecs.first
    org1.save
    biospecs.first.ordered_members << imagingEvent
    imagingEvent.ordered_members << media1
    biospecs.first.save
    imagingEvent.save
    media1.member_of_collections << team1
    media1.save
    project1.member_of_collections << team1
    project1.save
  end

  describe 'po_ids_by_org(org)' do
    it 'returns po ids by org' do
      results = subject.po_ids_by_org(org1)
      expect(results).to include(biospecs.first.id)
    end
  end

  describe 'total_media_by_po_ids(po_ids)' do
    it 'returns media count with po ids' do
      results = subject.total_media_by_po_ids([biospecs.first.id])
      expect(results).to eq(1)
    end
  end

  describe 'total_media_by_collection(collection_id)' do
    it 'returns media count by collection_id' do
      results = subject.total_media_by_collection(team1.id)
      expect(results).to eq(1)
    end
  end

  describe 'total_po_by_collection(collection_id)' do
    it 'returns po count by collection_id' do
      results = subject.total_po_by_collection(team1.id)
      expect(results).to eq(1)
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
      expect(facets["media_physical_object_type_sim"]["Biological Specimen"]).to eq(1)
      expect(total_media).to eq(1)
    end
  end

  describe 'media_type_and_modality_facets' do
    it 'returns media_type_and_modality_facets, media count' do
      facets, total_media = subject.media_type_and_modality_facets
      expect(facets["media_type_sim"]["xyz"]).to eq(1)
      expect(facets["media_modality_sim"]["modality abc"]).to eq(1)
      expect(total_media).to eq(1)
    end
  end

end
