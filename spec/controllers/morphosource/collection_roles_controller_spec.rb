require 'rails_helper'

RSpec.describe CollectionRolesController, type: :controller do
  let(:manager)               { User.create(email: 'test@test.com', password: 'password') }
  let(:another_user)          { User.create(email: 'email@email.com', password: 'password') }
  let(:team_collection_type)  { Hyrax::CollectionType.create(title: 'Team', machine_id: 88) }
  let(:team)                  { Collection.create(title: ['Team_A'], collection_type_gid: team_collection_type.gid, depositor: manager.ms_id) }
  let(:team2)                 { Collection.create(title: ['Team_A'], collection_type_gid: team_collection_type.gid, depositor: another_user.ms_id) }

  before do
    allow(Collection).to receive(:find).with(team.id).and_return(team)
    allow(Collection).to receive(:find).with(team2.id).and_return(team2)
    allow(User).to receive(:find_by).with(ms_id: another_user.ms_id).and_return(another_user)
    allow(User).to receive(:find_by).with(ms_id: manager.ms_id).and_return(manager)

    sign_in manager
  end

  describe '#update_collection_groups' do
    context 'current_user is not a collection manager' do
      before do
        allow(subject).to receive(:can?).with(:manage, team).and_return(false)
      end
      let(:params) { { collection_roles: { agent_type: 'user', remove: 'false', access: 'managers', agent_id: another_user.ms_id }, id: team.id } }

      it 'does not update the collection groups' do
        expect { process :update_collection_groups, method: :post, params: params }.not_to change { team.group_members.count }
      end
    end
    context 'adding an individual user' do
      let(:params) { { collection_roles: { agent_type: 'user', remove: 'false', access: '', agent_id: another_user.ms_id }, id: team.id } }
      before do
        allow(subject).to receive(:can?).with(:manage, team).and_return(true)
      end

      context 'manager adds another user as a manager' do
        before do
          params[:collection_roles][:access] = 'managers'
        end
        it "adds the user to the collection's manager role" do
          post :update_collection_groups, params: params
          expect(team.managers).to include(another_user)
        end
      end

      context 'manager adds another user as a depositor' do
        before do
          params[:collection_roles][:access] = 'depositors'
        end
        it "adds the user to the collection's depositor role" do
          post :update_collection_groups, params: params
          expect(team.depositors).to include(another_user)
        end
      end

      context 'manager adds another user as a viewer' do
        before do
          params[:collection_roles][:access] = 'viewers'
        end
        it "adds the user to the collection's viewer role" do
          post :update_collection_groups, params: params
          expect(team.viewers).to include(another_user)
        end
      end

      context 'the user already has a role in the collection' do
        before do
          params[:collection_roles][:access] = 'depositors'
          params[:collection_roles][:agent_id] = manager.ms_id
        end
        it "does not add the user to the collection's group members" do
          post :update_collection_groups, params: params
          expect(team.depositors).not_to include(manager)
        end
      end
    end

    context 'removing an individual user' do
      let(:params) { { collection_roles: { agent_type: 'user', new_access: 'remove', access: '', agent_id: another_user.ms_id }, id: team.id } }
      before do
        team.user_groups.each do |group|
          group.users << another_user
          group.save
        end
        allow(subject).to receive(:can?).with(:manage, team).and_return(true)
      end

      context 'manager removes another user as a manager' do
        before do
          params[:collection_roles][:access] = 'managers'
        end
        it 'removes the user from the managers group' do
          post :update_collection_groups, params: params
          expect(team.managers).not_to include(another_user)
        end
      end

      context 'manager removes another user as a depositor' do
        before do
          params[:collection_roles][:access] = 'depositors'
        end
        it 'removes the user from the depositors group' do
          post :update_collection_groups, params: params
          expect(team.depositors).not_to include(another_user)
        end
      end

      context 'manager removes another user as a viewer' do
        before do
          params[:collection_roles][:access] = 'viewers'
        end
        it 'removes the user from the viewers group' do
          post :update_collection_groups, params: params
          expect(team.viewers).not_to include(another_user)
        end
      end
    end

    context 'moving users to different roles' do
      let(:params) { { collection_roles: { agent_type: 'user', new_access: '', access: '', agent_id: another_user.ms_id }, id: team.id } }
      before do
        allow(subject).to receive(:can?).with(:manage, team).and_return(true)
      end
      context 'manager moves a user from manager to depositor' do
        before do
          params[:collection_roles][:access] = 'managers'
          params[:collection_roles][:new_access] = 'depositors'
          team.managers_group.users << another_user
          team.save
        end
        it 'moves the user to the correct group' do
          post :update_collection_groups, params: params
          expect(team.managers).not_to include(another_user)
          expect(team.depositors).to include(another_user)
        end
      end
      context 'manager moves a user from manager to viewer' do
        before do
          params[:collection_roles][:access] = 'managers'
          params[:collection_roles][:new_access] = 'viewers'
          team.managers_group.users << another_user
          team.save
        end
        it 'moves the user to the correct group' do
          post :update_collection_groups, params: params
          expect(team.managers).not_to include(another_user)
          expect(team.viewers).to include(another_user)
        end
      end
      context 'manager moves a user from depositor to manager' do
        before do
          params[:collection_roles][:access] = 'depositors'
          params[:collection_roles][:new_access] = 'managers'
          team.depositors_group.users << another_user
          team.save
        end
        it 'moves the user to the correct group' do
          post :update_collection_groups, params: params
          expect(team.depositors).not_to include(another_user)
          expect(team.managers).to include(another_user)
        end
      end
      context 'manager moves a user from depositor to viewer' do
        before do
          params[:collection_roles][:access] = 'depositors'
          params[:collection_roles][:new_access] = 'viewers'
          team.depositors_group.users << another_user
          team.save
        end
        it 'moves the user to the correct group' do
          post :update_collection_groups, params: params
          expect(team.depositors).not_to include(another_user)
          expect(team.viewers).to include(another_user)
        end
      end
      context 'manager moves a user from viewer to manager' do
        before do
          params[:collection_roles][:access] = 'viewers'
          params[:collection_roles][:new_access] = 'managers'
          team.viewers_group.users << another_user
          team.save
        end
        it 'moves the user to the correct group' do
          post :update_collection_groups, params: params
          expect(team.viewers).not_to include(another_user)
          expect(team.managers).to include(another_user)
        end
      end
      context 'manager moves a user from viewer to depositor' do
        before do
          params[:collection_roles][:access] = 'viewers'
          params[:collection_roles][:new_access] = 'depositors'
          team.viewers_group.users << another_user
          team.save
        end
        it 'moves the user to the correct group' do
          post :update_collection_groups, params: params
          expect(team.viewers).not_to include(another_user)
          expect(team.depositors).to include(another_user)
        end
      end
    end

    context 'adding annother team' do
      let(:params)  { { collection_roles: { agent_type: 'group', access: '', team_collection_id: team2.id }, id: team.id } }
      let(:user3)   { User.create(email: 'blah@blah.com', password: 'password') }

      before do
        allow(subject).to receive(:can?).with(:manage, team).and_return(true)
        allow(subject).to receive(:can?).with(:manage, team2).and_return(true)
        allow(team2).to receive(:group_members).and_return([another_user, user3])
      end

      context 'collection manager does not manage the other team' do
        before do
          allow(subject).to receive(:can?).with(:manage, team2).and_return(false)
          params[:collection_roles][:access] = 'viewers'
        end
        it "does not add the other team's members to the collection" do
          post :update_collection_groups, params: params
          expect(team.viewers).not_to include(another_user, user3)
        end
      end

      context 'manager adds another team as a managers' do
        before do
          params[:collection_roles][:access] = 'managers'
        end
        it "adds the other team's members to the collection" do
          post :update_collection_groups, params: params
          expect(team.managers).to include(another_user, user3)
        end
      end

      context 'manager adds another team as a depositors' do
        before do
          params[:collection_roles][:access] = 'depositors'
        end
        it "adds the other team's members to the collection" do
          post :update_collection_groups, params: params
          expect(team.depositors).to include(another_user, user3)
        end
      end

      context 'manager adds another team as a viewers' do
        before do
          params[:collection_roles][:access] = 'viewers'
        end
        it "adds the other team's members to the collection" do
          post :update_collection_groups, params: params
          expect(team.viewers).to include(another_user, user3)
        end
      end

      context 'some team members already have a collection role' do
        before do
          params[:collection_roles][:access] = 'viewers'
          allow(team).to receive(:group_members).and_return([manager, another_user])
        end
        it "adds only the other team's members that don't already belong to the collection's group members to the collection" do
          post :update_collection_groups, params: params
          expect(team.viewers).to include(user3)
          expect(team.viewers).not_to include(another_user)
        end
      end
    end
  end
end
