require 'rails_helper'

RSpec.describe Hyrax::TeamsController do


  let(:ability) { double Ability }

  let(:team_collection_type) { Hyrax::CollectionType.create(title: 'Team', machine_id: 88) }
  let(:project_collection_type) { Hyrax::CollectionType.create(title: 'Project', machine_id: 77) }
  let(:another_collection_type) { Hyrax::CollectionType.create(title: 'Another', machine_id: 99) }
  let(:user) { User.create(display_name: 'John Doe', email: 'johndoe@email.com', password: 'password', ms_id: 'abc123') }

  let(:team) { Collection.create(title: ['Team_B'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id) }

  let(:project) { Collection.create(title: ['Project_B'], collection_type_gid: project_collection_type.gid, depositor: user.ms_id) }

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
    team.create_collection_groups
  end

  let(:presenter) { described_class.new(SolrDocument.new(team.to_solr), ability, nil) }
  let(:presenter2) { described_class.new(SolrDocument.new(project.to_solr), ability, nil) }


  it 'has a teams route' do
    route = { controller: 'hyrax/teams', action: 'show', id: team.id }
    expect(:get => '/teams/'+team.id).to route_to(route)
  end

  it 'has a projects route' do
    route = { controller: 'hyrax/teams', action: 'show', id: project.id }
    expect(:get => '/projects/'+project.id).to route_to(route)
  end

end
