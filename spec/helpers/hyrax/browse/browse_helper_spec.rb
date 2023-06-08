require 'rails_helper'

RSpec.describe Hyrax::Browse::BrowseHelper, type: :helper do

  let(:public)      { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
  let(:ability) { double Ability }

  let!(:org1)  { Organization.create(title: ['title'], organization_type: ["foobar"]) }
  let!(:specimen) { BiologicalSpecimen.create(title: [ 'abc:123' ], catalog_number: [ '123' ], institution_code: [ 'INST1' ], collection_code: [ 'abc' ], vouchered: [ "Yes" ], organization_id: [ org1.id ] ) }

  let!(:user) { User.create(display_name: 'John Doe', email: 'johndoe@email.com', password: 'password', ms_id: 'abc123') }
  let!(:team1) { Collection.create(title: ['Team_B'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id, visibility: public) }

  let(:project1) { Collection.create(title: ['Project_B'], collection_type_gid: project_collection_type.gid, depositor: user.ms_id, visibility: public) }
  let!(:media1) {
    Media.create( title: ["Test Media Work"],
                  media_type: ["xyz"]
                  )
  }
  let(:device)  { Device.create(title: ['device'], modality: ['Photogrammetry']) }
  let!(:imagingEvent)     { ImagingEvent.create(title: ['imagingEvent'], depositor: user.ms_id, ie_modality: device.modality, device_id: [device.id], physical_object_id: [specimen.id]) }

  before do
    imagingEvent.ordered_members << media1
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
      expect(@modality_facets[device.modality.first]).to eq(1)
      expect(@total_media).to eq(1)
    end
  end

  describe 'media_count_by_media_type' do
    let(:media_types) { YAML.load_file('config/authorities/media_types.yml') }
    let(:type_ids)    { media_types["terms"].map{ |term| term["id"] } }

    let(:media_type_facets) { {"Image"=>3, "CTImageSeries"=>5, "Mesh"=>7, "Other"=>9, "PhotogrammetryImageSeries"=>11, "Video"=>13, "SequentialSectionImageSeries"=>15} }

    before do
      helper.instance_variable_set(:@media_type_facets, media_type_facets)
    end

    it 'returns correct counts' do
      type_ids.each do |type|
        expect(helper.media_count_by_media_type(type)).to eq(media_type_facets[type])
      end
    end
  end
end
