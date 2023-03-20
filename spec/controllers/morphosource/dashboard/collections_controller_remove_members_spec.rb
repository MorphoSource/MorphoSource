require 'rails_helper'
require 'spec_helper'
require 'morphosource/dashboard/collections_controller'
require 'hyrax/dashboard/collections_controller'

RSpec.describe Morphosource::Dashboard::Collections::TeamsController, type: :controller do

  let(:user)                  { User.create(email: 'email@email.com', password: 'password') }
  let(:team_collection_type)  { Hyrax::CollectionType.create(Morphosource::CollectionTypes::Teams::SETTINGS) }
  let(:team)                  { Collection.create(title: ['Team'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id) }
  let(:team2)                 { Collection.create(title: ['Team2'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id) }

  let(:work)                  { Media.create(title: ['Test Work'], depositor: user.ms_id) }
  let(:ability)               { Ability.new(user) }

  before do
    allow(subject.current_user).to receive(:user?).and_return(true)
    sign_in user
    team.create_collection_groups
    Morphosource::Collections::PermissionsCreateService.create_default(collection: team)
    work.member_of_collections << team
    Hyrax::PermissionTemplateApplicator.apply(team.permission_template).to(model: work)
    work.edit_users += [user.ms_id]
    work.save
    allow(subject).to receive(:current_ability).and_return(ability)
    allow(ability).to receive(:can?).and_call_original
  end

  describe 'update' do
    before do
      allow(ability).to receive(:can?).with(:update, team).and_return(true)
      allow(ability).to receive(:can?).with(:edit, work.id).and_return(true)
    end

    describe 'removing works from the collection' do

      it 'redirects to the collection media page' do
        put :update, params: { id: team.id, collection: { members: 'remove' }, batch_document_ids: [ work.id ] }
        expect(response).to redirect_to(team_path(team.id))
      end

      context 'removing a single work' do
        before do
          put :update, params: { id: team.id, collection: { members: 'remove' }, batch_document_ids: [ work.id ] }
        end

        it 'removes the association' do
          work.reload
          expect(team.member_objects).not_to include(work)
          expect(work.member_of_collections).not_to include(team)
        end

        it 'removes team permissions' do
          work.reload
          expect(work.edit_users).to match_array([user.ms_id])
          expect(work.read_groups).to match_array([])
          expect(work.download_groups).to match_array([])
          expect(work.edit_groups).to match_array(['admin'])
        end
      end

      context 'the work is in another collection' do
        before do
          team2.create_collection_groups
          Morphosource::Collections::PermissionsCreateService.create_default(collection: team2)
          work.member_of_collections << team2
          Hyrax::PermissionTemplateApplicator.apply(team2.permission_template).to(model: work)
          work.save
          put :update, params: { id: team.id, collection: { members: 'remove' }, batch_document_ids: [ work.id ] }
        end

        it 'removes the association' do
          work.reload
          expect(team.member_objects).not_to include(work)
          expect(team2.member_objects).to include(work)
          expect(work.member_of_collections).not_to include(team)
          expect(work.member_of_collections).to include(team2)
        end

        it "removes only one team's permissions" do
          work.reload
          expect(work.edit_users).to match_array([user.ms_id])
          expect(work.read_groups).to match_array([team2.viewers_group.name])
          expect(work.download_groups).to match_array([team2.downloaders_group.name])
          expect(work.edit_groups).to match_array([ team2.editors_group.name, team2.managers_group.name, 'admin'])
        end
      end
    end
  end
end
