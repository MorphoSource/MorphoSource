require 'rails_helper'

RSpec.describe Hyrax::Dashboard::CollectionsController, type: :controller do
  routes { Hyrax::Engine.routes }

  let(:public)      { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }

  let(:ability) { double Ability }

  let(:team_collection_type) { Hyrax::CollectionType.create(title: 'Team', machine_id: 88) }
  let(:project_collection_type) { Hyrax::CollectionType.create(title: 'Project', machine_id: 77) }
  let(:another_collection_type) { Hyrax::CollectionType.create(title: 'Another', machine_id: 99) }
  let(:user) { User.create(display_name: 'John Doe', email: 'johndoe@email.com', password: 'password', ms_id: 'abc123') }

  let(:team) { Collection.create(title: ['Team_B'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id, visibility: public) }

  let(:admin_role)  { Role.create(name: 'admin') }
  let(:presenter) { described_class.new(SolrDocument.new(team.to_solr), ability, nil) }

  before do
    team.create_collection_groups
  end

  describe 'edit access users should be redirected to edit' do
    before do
      admin_role.users << user
      admin_role.save
      sign_in user
      allow(subject.current_user).to receive(:can?).with(:edit, team).and_return(true)
    end
    it 'edit access users should be redirected to edit page' do
      get :show, params: { id: team.id }
      expect(response).to redirect_to "/dashboard/collections/000200000/edit?locale=en&"
    end
  end

  describe 'read access users should be redirected to view' do
    before do
      sign_in user
      allow(subject.current_user).to receive(:can?).with(:edit, team).and_return(false)
    end
    it 'read access users should be redirected to public view' do
      get :show, params: { id: team.id }
      expect(response).to redirect_to "/teams/000200000?locale=en"
    end
  end

end
