require 'rails_helper'

RSpec.describe Hyrax::Browse::BrowseHelper, type: :helper do

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

  describe 'get_media_po_type_info' do
    before do
      get_media_po_type_info
    end
    it 'returns media po type info' do
      expect(@total_bso_media).to eq(1)
      expect(@total_cho_media).to eq(0)
      expect(@total_media).to eq(1)
    end
  end

  describe 'get_media_type_and_modality_info' do
    before do
      get_media_type_and_modality_info
    end
    it 'returns media type and modality info' do
      expect(@media_type_facets["xyz"]).to eq(1)
      expect(@modality_facets["modality abc"]).to eq(1)
      expect(@total_media).to eq(1)
    end
  end

end
