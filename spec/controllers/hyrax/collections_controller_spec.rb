require 'rails_helper'

RSpec.describe Hyrax::CollectionsController do
  routes { Hyrax::Engine.routes }

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
      postal_code: ["postal_code"],
      country: ["country"],
      team_id: [team.id]
    )
  }


  let(:presenter) { described_class.new(SolrDocument.new(team.to_solr), ability, nil) }

  scenario 'teams collections should redirect to /teams' do
    get :show, params: { id: team.id }
    expect(response).to redirect_to "/teams/" + team.id + "?locale=en"
  end

  scenario 'projects collections should redirect to /projects' do
    get :show, params: { id: project.id }
    expect(response).to redirect_to "/projects/" + project.id + "?locale=en"
  end


end
