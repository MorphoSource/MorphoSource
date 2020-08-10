require 'rails_helper'

RSpec.describe Morphosource::CollectionHelper, type: :helper do

  let(:public)      { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
  let(:ability) { double Ability }
  let(:team_collection_type) { Hyrax::CollectionType.create(title: 'Team', machine_id: 88) }
  let(:project_collection_type) { Hyrax::CollectionType.create(title: 'Project', machine_id: 77) }
  let(:another_collection_type) { Hyrax::CollectionType.create(title: 'Another', machine_id: 99) }
  let(:user) { User.create(display_name: 'John Doe', email: 'johndoe@email.com', password: 'password', ms_id: 'abc123') }
  let(:team) { Collection.create(title: ['Team_B'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id, visibility: public) }
  let(:project) { Collection.create(title: ['Project_B'], collection_type_gid: project_collection_type.gid, depositor: user.ms_id, visibility: public) }
  let(:role) { Role.new(name: 'role') }
  let!(:org1)                  { Organization.create(title: ['old organization'], institution_code: ['DEF'], team_id: [team.id]) }

  let(:specimen)         { BiologicalSpecimen.create(title: ['specimen'], vouchered: [true], depositor: user.ms_id) }
  let(:imagingEvent)     { ImagingEvent.create(title: ['imagingEvent'], depositor: user.ms_id) }
  let(:cho)         { CulturalHeritageObject.create(title: ['cho title'], vouchered: [true], depositor: user.ms_id) }
  let(:imagingEvent2)     { ImagingEvent.create(title: ['imagingEvent2'], depositor: user.ms_id) }
  let(:media)            { Media.create(title: ['new media'], depositor: user.ms_id) }
  let(:media2)            { Media.create(title: ['new media 2'], depositor: user.ms_id) }
  let(:team_manager)     { User.create(email: 'manager@test.com', password: 'password') }
  let(:team_depositor)   { User.create(email: 'depositor@test.com', password: 'password') }
  let(:team_viewer)      { User.create(email: 'viewer@test.com', password: 'password') }
  let(:works)             { [org1, specimen, imagingEvent, media, media2, cho, imagingEvent2] }

  let(:presenter) { described_class.new(SolrDocument.new(team.to_solr), ability, nil) }

  before do

    org1.ordered_members << specimen
    specimen.ordered_members << imagingEvent
    imagingEvent.ordered_members << media
    media2.member_of_collections = [project]
    cho.ordered_members << imagingEvent2
    imagingEvent2.ordered_members << media2

    works.each(&:save)
    works.each(&:reload)

    team.create_collection_groups
#    sign_in user
    allow(ability).to receive(:can?).with(:edit, team.id).and_return(true)

  end

  describe '#organization_from_bso(bso)' do
    it 'returns the organization' do
      expect(helper.organization_from_bso(specimen).id).to eq(org1.id)
    end
  end

  describe '#hidden_params_for_filters' do
    let(:params) { { 'view' => 'gallery' } }
    before do
      allow(helper).to receive(:request_params) { params }
    end
    it 'returns hidden form field for view=gallery' do
      results = helper.hidden_params_for_filters('m_')
      expect(results).to eq ("<input type=\"hidden\" name=\"view\" value=\"gallery\" />")
    end
  end

  describe '#ms_collection_view_link' do
    let(:uri) {'dashboard/collections'}
    let(:view) {{:view=>:list}}
    before do
      allow(helper).to receive(:path_info) { uri }   
    end
    it 'returns correct link' do
      expect(helper.ms_collection_view_link(team.id, view)).to eq ("/dashboard/collections/"+team.id+"?view=list") 
    end
  end

end

