require 'rails_helper'

include Warden::Test::Helpers

RSpec.feature 'Test redirects for teams and projects', js: true do

  let(:public)      { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }

  let(:ability) { double Ability }

  let(:team_collection_type) { Hyrax::CollectionType.create(title: 'Team', machine_id: 88) }
  let(:project_collection_type) { Hyrax::CollectionType.create(title: 'Project', machine_id: 77) }
  let(:another_collection_type) { Hyrax::CollectionType.create(title: 'Another', machine_id: 99) }
  let(:user) { User.create(display_name: 'John Doe', email: 'johndoe@email.com', password: 'password', ms_id: 'abc123') }

  let(:team) { Collection.create(title: ['Team_B'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id, visibility: public) }

  let(:project) { Collection.create(title: ['Project_B'], collection_type_gid: project_collection_type.gid, depositor: user.ms_id, visibility: public) }

  let(:role) { Role.new(name: 'role') }

  let!(:org1)  {
    Organization.create(
      title: ['title'],
      institution_name: ["institution_name"],
      institution_code: ["institution_code"],
      collection_code: ["collection_code"],
      description: ["description"],
      address: ["address"],
      city: ["city"],
      state_province: ["state_province"],
      country: ["country"],
      team_id: [team.id]
    )
  }


  before do
    allow(Role).to receive(:find_by).and_return(role)
    Morphosource::Collections::PermissionsCreateService.create_default(collection: team)
    Morphosource::Collections::PermissionsCreateService.create_default(collection: project)
    team.create_collection_groups
  end

  let(:presenter) { described_class.new(SolrDocument.new(team.to_solr), ability, nil) }


  scenario 'teams collections should redirect to /teams' do
    visit '/collections/' + team.id
    expect(page.current_path).to eq("/teams/" + team.id)
  end

  scenario 'projects collections should redirect to /projects' do
    visit '/collections/' + project.id
    expect(page.current_path).to eq("/projects/" + project.id)
  end

end
