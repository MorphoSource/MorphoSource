# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionRolesController, type: :controller do

  include TestHelpers

  let(:manager)             { FactoryBot.create(:contributor) }
  let(:another_user)        { FactoryBot.create(:contributor) }
  let(:user3)               { FactoryBot.create(:contributor) }
  let(:user4)               { FactoryBot.create(:contributor) }
  let(:team)                { FactoryBot.create(:team, title: ['Team'], depositor: manager.ms_id) }
  let(:team2)               { FactoryBot.create(:team, title: ['Team2'], depositor: another_user.ms_id) }

  let(:user_status_message) { "The user (#{another_user.email}) can't be added to the #{params[:collection_roles][:access]} role because they do not have contributor status. Either add the user to a membership role that does not require contributor status (downloader, viewer) or have the user request contributor status." }

  before do
    sign_in manager
  end

  describe '#update_collection_groups' do
    before do
      team.create_collection_groups
    end

    context 'current_user is not a collection manager' do
      let(:params) { { collection_roles: { agent_type: 'user', remove: 'false', access: 'managers', agent_id: another_user.ms_id }, id: team.id } }

      before do
        allow(subject).to receive(:can?).with(:edit, team).and_return(false)
      end

      it 'does not update the collection groups' do
        expect { process :update_collection_groups, method: :post, params: params }.not_to change { team.group_members.count }
      end
    end

    context 'adding an individual user' do
      let(:params) { { collection_roles: { agent_type: 'user', remove: 'false', access: '', agent_id: another_user.ms_id }, id: team.id } }

      before do
        allow(subject).to receive(:can?).with(:edit, team).and_return(true)
        allow(subject).to receive(:update_subcollections).and_return(true)
      end

      context 'user already has a role in the collection' do
        before do
          set_access_params('managers')
          team.editors << another_user
          team.editors_group.save
          post :update_collection_groups, params: params
        end
        it "does not add the user to the collection's manager role" do
          expect(team.managers).not_to include(another_user)
        end
        it 'creates a flash message with the user name' do
          expect(flash[:error]).to match("#{another_user.name} is already a member of #{team.title.first}")
        end
      end

      context 'manager adds another user as a manager' do
        before do
          set_access_params('managers')
        end

        context 'user is a contributor' do
          before do
            is_contributor(another_user)
          end
          it "adds the user to the collection's manager role" do
            post :update_collection_groups, params: params
            expect(team.managers).to include(another_user)
          end
        end

        context 'user is not a contributor' do
          before do
            is_not_contributor(another_user)
            post :update_collection_groups, params: params
          end
          it "does not add the user to the collection's manager role" do
            expect(team.managers).not_to include(another_user)
          end
          it 'creates a flash message with the user name' do
            expect(flash[:error]).to match(user_status_message)
          end
        end
      end

      context 'manager adds another user as a depositor' do
        before do
          set_access_params('depositors')
        end

        context 'user is a contributor' do
          before do
            is_contributor(another_user)
          end
          it "adds the user to the collection's depositor role" do
            post :update_collection_groups, params: params
            expect(team.depositors).to include(another_user)
          end
        end

        context 'user is not a contributor' do
          before do
            is_not_contributor(another_user)
            post :update_collection_groups, params: params
          end
          it "does not add the user to the collection's depositor role" do
            expect(team.depositors).not_to include(another_user)
          end
          it 'creates a flash message with the user name' do
            expect(flash[:error]).to match(user_status_message)
          end
        end
      end

      context 'manager adds another user as a viewer' do
        before do
          set_access_params('viewers')
        end
        it "adds the user to the collection's viewer role" do
          post :update_collection_groups, params: params
          expect(team.viewers).to include(another_user)
        end
      end

      context 'the user already has a role in the collection' do
        before do
          set_access_params('depositors')
          params[:collection_roles][:agent_id] = manager.ms_id
          is_contributor(manager)
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
        allow(subject).to receive(:can?).with(:edit, team).and_return(true)
        allow(subject).to receive(:update_subcollections).and_return(true)
      end

      context 'manager removes another user as a manager' do
        before do
          set_access_params('managers')
        end
        it 'removes the user from the managers group' do
          post :update_collection_groups, params: params
          expect(team.managers).not_to include(another_user)
        end
      end

      context 'manager removes another user as a depositor' do
        before do
          set_access_params('depositors')
        end
        it 'removes the user from the depositors group' do
          post :update_collection_groups, params: params
          expect(team.depositors).not_to include(another_user)
        end
      end

      context 'manager removes another user as a viewer' do
        before do
          set_access_params('viewers')
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
        allow(subject).to receive(:can?).with(:edit, team).and_return(true)
        allow(subject).to receive(:update_subcollections).and_return(true)
      end
      context 'manager moves a user from manager to depositor' do
        before do
          set_access_params('managers')
          set_new_access_params('depositors')
          team.managers_group.users << another_user
          team.save
        end
        context 'user is a contributor' do
          before do
            is_contributor(another_user)
          end
          it 'moves the user to the correct group' do
            post :update_collection_groups, params: params
            expect(team.managers).not_to include(another_user)
            expect(team.depositors).to include(another_user)
          end
        end
        context 'user is not a contributor' do
          before do
            is_not_contributor(another_user)
            post :update_collection_groups, params: params
          end
          it 'does not move the user to the new group' do
            expect(team.managers).to include(another_user)
            expect(team.depositors).not_to include(another_user)
          end
          it 'creates a flash message with the user name' do
            expect(flash[:error]).to match(user_status_message)
          end
        end
      end
      context 'manager moves a user from manager to viewer' do
        before do
          set_access_params('managers')
          set_new_access_params('viewers')
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
          set_access_params('depositors')
          set_new_access_params('managers')
          team.depositors_group.users << another_user
          team.save
        end
        context 'user is not a contributor' do
          before do
            is_not_contributor(another_user)
            post :update_collection_groups, params: params
          end
          it 'does not move the user to the new group' do
            expect(team.depositors).to include(another_user)
            expect(team.managers).not_to include(another_user)
          end
          it 'creates a flash message with the user name' do
            expect(flash[:error]).to match(user_status_message)
          end
        end
        context 'user is a contributor' do
          before do
            is_contributor(another_user)
          end
          it 'moves the user to the correct group' do
            post :update_collection_groups, params: params
            expect(team.depositors).not_to include(another_user)
            expect(team.managers).to include(another_user)
          end
        end
      end
      context 'manager moves a user from depositor to viewer' do
        before do
          set_access_params('depositors')
          set_new_access_params('viewers')
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
          set_access_params('viewers')
          set_new_access_params('managers')
          team.viewers_group.users << another_user
          team.save
        end
        context 'user is not a contributor' do
          before do
            is_not_contributor(another_user)
            post :update_collection_groups, params: params
          end
          it 'does not move the user to the new group' do
            expect(team.viewers).to include(another_user)
            expect(team.managers).not_to include(another_user)
          end
          it 'creates a flash message with the user name' do
            expect(flash[:error]).to match(user_status_message)
          end
        end
        context 'user is a contributor' do
          before do
            is_contributor(another_user)
          end
          it 'moves the user to the correct group' do
            post :update_collection_groups, params: params
            expect(team.viewers).not_to include(another_user)
            expect(team.managers).to include(another_user)
          end
        end
      end
      context 'manager moves a user from viewer to depositor' do
        before do
          set_access_params('viewers')
          set_new_access_params('depositors')
          team.viewers_group.users << another_user
          team.save
        end
        context 'user is not a contributor' do
          before do
            is_not_contributor(another_user)
            post :update_collection_groups, params: params
          end
          it 'does not move the user' do
            expect(team.viewers).to include(another_user)
            expect(team.depositors).not_to include(another_user)
          end
          it 'creates a flash message with the user name' do
            expect(flash[:error]).to match(user_status_message)
          end
        end
        context 'user is a contributor' do
          before do
            is_contributor(another_user)
          end
          it 'moves the user to the correct group' do
            post :update_collection_groups, params: params
            expect(team.viewers).not_to include(another_user)
            expect(team.depositors).to include(another_user)
          end
        end
      end
    end

    context 'adding another team' do
      let(:params)  { { collection_roles: { agent_type: 'group', access: '', team_collection_id: team2.id }, id: team.id } }

      before do
        allow(subject).to receive(:can?).with(:edit, team).and_return(true)
        allow(subject).to receive(:can?).with(:edit, team2).and_return(true)
        allow(team2).to receive(:group_members).and_return([another_user, user3])
        allow(subject).to receive(:update_subcollections).and_return(true)
        team2.create_collection_groups
      end

      context 'collection manager does not manage the other team' do
        before do
          allow(subject).to receive(:can?).with(:edit, team2).and_return(false)
          set_access_params('viewers')
        end
        it "does not add the other team's members to the collection" do
          post :update_collection_groups, params: params
          expect(team.viewers).not_to include(another_user, user3)
        end
      end

      context 'manager adds another team as a managers' do
        before do
          set_access_params('managers')
        end
        context 'one of the team members is not a contributor' do
          before do
            is_not_contributor(another_user)
            post :update_collection_groups, params: params
          end
          it "does not add the other team's members to the collection" do
            expect(team.managers).not_to include(another_user, user3)
          end
          it 'creates a flash message with the user name' do
            expect(flash[:error]).to match(user_status_message)
          end
        end
        context 'all the team members are contributors' do
          before do
            is_contributor(another_user)
          end
          it "adds the other team's members to the collection" do
            post :update_collection_groups, params: params
            expect(team.managers).to include(another_user, user3)
          end
        end

      end

      context 'manager adds another team as a depositors' do
        before do
          set_access_params('depositors')
        end
        context 'one of the team members is not a contributor' do
          before do
            is_not_contributor(another_user)
            post :update_collection_groups, params: params
          end
          it "does not add the other team's members to the collection" do
            expect(team.depositors).not_to include(another_user, user3)
          end
          it 'creates a flash message with the user name' do
            expect(flash[:error]).to match(user_status_message)
          end
        end
        context 'all the team members are contributors' do
          before do
            is_contributor(another_user)
          end
          it "adds the other team's members to the collection" do
            post :update_collection_groups, params: params
            expect(team.depositors).to include(another_user, user3)
          end
        end
      end

      context 'manager adds another team as a viewers' do
        before do
          set_access_params('viewers')
        end
        it "adds the other team's members to the collection" do
          post :update_collection_groups, params: params
          expect(team.viewers).to include(another_user, user3)
        end
      end

      context 'some team members already have a collection role' do
        before do
          set_access_params('viewers')
          allow(team).to receive(:group_members).and_return([manager, another_user])
        end
        it "adds only the other team's members that don't already belong to the collection's group members to the collection" do
          post :update_collection_groups, params: params
          expect(team.viewers).to include(user3)
          expect(team.viewers).not_to include(another_user)
        end
      end
    end

    context 'team has subcollections' do
      let(:project_a)     { FactoryBot.create(:project, title: ['Project_A'], depositor: manager.ms_id) }
      let(:project_b)     { FactoryBot.create(:project, title: ['Project_B'], depositor: manager.ms_id) }

      let(:projects_solr) { [SolrDocument.new(project_a.to_solr), SolrDocument.new(project_b.to_solr)] }

      let(:params)        { { collection_roles: { agent_type: 'user', remove: 'false', access: '', agent_id: another_user.ms_id }, id: team.id } }

      before do
        project_a.create_collection_groups
        project_b.create_collection_groups
        allow(subject).to receive(:can?).with(:edit, team).and_return(true)
        allow(subject).to receive(:find_subcollections).and_return(true)
        subject.instance_variable_set(:@subcollection_docs, projects_solr)
      end

      context 'manager adds another user as a manager' do
        before do
          set_access_params('managers')
        end
        context 'user is not a contributor' do
          before do
            is_not_contributor(another_user)
            post :update_collection_groups, params: params
          end
          it "does not add the user to the subcollections' manager role" do
            expect(project_a.managers).not_to include(another_user)
            expect(project_b.managers).not_to include(another_user)
          end
          it 'creates a flash message with the user name' do
            expect(flash[:error]).to match(user_status_message)
          end
        end
        context 'user is a contributor' do
          before do
            is_contributor(another_user)
          end
          it "adds the user to the subcollections' manager role" do
            post :update_collection_groups, params: params
            expect(project_a.managers).to include(another_user)
            expect(project_b.managers).to include(another_user)
          end
        end
      end

      context 'manager adds another user as a depositor' do
        before do
          set_access_params('depositors')
        end
        context 'user is not a contributor' do
          before do
            is_not_contributor(another_user)
            post :update_collection_groups, params: params
          end
          it "does not add the user to the subcollections' depositor role" do
            expect(project_a.depositors).not_to include(another_user)
            expect(project_b.depositors).not_to include(another_user)
          end
          it 'creates a flash message with the user name' do
            expect(flash[:error]).to match(user_status_message)
          end
        end
        context 'user is a contributor' do
          before do
            is_contributor(another_user)
          end
          it "adds the user to the subcollections' depositor role" do
            post :update_collection_groups, params: params
            expect(project_a.depositors).to include(another_user)
            expect(project_b.depositors).to include(another_user)
          end
        end
      end

      context 'manager adds another user as a viewer' do
        before do
          set_access_params('viewers')
        end
        it "adds the user to the subcollections' viewer role" do
          post :update_collection_groups, params: params
          expect(project_a.viewers).to include(another_user)
          expect(project_b.viewers).to include(another_user)
        end
      end

      context 'manager removes a user from the manager role' do
        before do
          set_access_params('managers')
          set_new_access_params('remove')
          [team, project_a, project_b].each do |collection|
            collection.managers << another_user
            collection.managers_group.save
          end
        end
        it "removes the user to the subcollections' manager role" do
          post :update_collection_groups, params: params
          expect(project_a.managers).not_to include(another_user)
          expect(project_b.managers).not_to include(another_user)
        end
      end

      context 'manager removes a user from the depositor role' do
        before do
          set_access_params('depositors')
          set_new_access_params('remove')
          [team, project_a, project_b].each do |collection|
            collection.depositors << another_user
            collection.depositors_group.save
          end
        end
        it "removes the user to the subcollections' depositor role" do
          post :update_collection_groups, params: params
          expect(project_a.depositors).not_to include(another_user)
          expect(project_b.depositors).not_to include(another_user)
        end
      end

      context 'manager removes a user from the viewer role' do
        before do
          set_access_params('viewers')
          set_new_access_params('remove')
          [team, project_a, project_b].each do |collection|
            collection.viewers << another_user
            collection.viewers_group.save
          end
        end
        it "removes the user to the subcollections' viewer role" do
          post :update_collection_groups, params: params
          expect(project_a.viewers).not_to include(another_user)
          expect(project_b.viewers).not_to include(another_user)
        end
      end

      context 'manager adds a user to the depositor role, one subcollection has the user already as a manager, the other has the user already as a viewer' do
        before do
          set_access_params('depositors')
          project_a.managers << another_user
          project_a.managers_group.save
          project_b.viewers << another_user
          project_b.viewers_group.save
        end
        context 'user is not a contributor' do
          before do
            is_not_contributor(another_user)
            post :update_collection_groups, params: params
          end
          it 'does not add the user to the team, and does not move the user to depositor access for each subcollection' do
            expect(team.depositors).not_to include(another_user)
            expect(project_a.depositors).not_to include(another_user)
            expect(project_a.managers).to include(another_user)
            expect(project_b.depositors).not_to include(another_user)
            expect(project_b.viewers).to include(another_user)
          end
          it 'creates a flash message with the user name' do
            expect(flash[:error]).to match(user_status_message)
          end
        end
        context 'user is a contributor' do
          before do
            is_contributor(another_user)
          end
          it 'adds the user to the team, and moves the user to depositor access for each subcollection' do
            post :update_collection_groups, params: params
            expect(team.depositors).to include(another_user)
            expect(project_a.depositors).to include(another_user)
            expect(project_a.managers).not_to include(another_user)
            expect(project_b.depositors).to include(another_user)
            expect(project_b.viewers).not_to include(another_user)
          end
        end
      end

      context 'manager adds another team to managers access' do
        let(:params)          { { collection_roles: { agent_type: 'group', access: '', team_collection_id: team2.id }, id: team.id } }
        let(:team_2_members)  { [another_user, user3, user4] }
        let(:all_users)       { [manager, another_user, user3, user4] }

        before do
          set_access_params('managers')
          allow(subject).to receive(:can?).with(:edit, team).and_return(true)
          allow(subject).to receive(:can?).with(:edit, team2).and_return(true)
          allow(team2).to receive(:group_members).and_return(team_2_members)
        end

        context 'one team member is not a contributor' do
          before do
            is_not_contributor(another_user)
            post :update_collection_groups, params: params
          end
          it 'does not add the other team members to subcollection managers' do
            expect(team.managers).not_to include(another_user, user3, user4)
            expect(project_a.managers).not_to include(another_user, user3, user4)
            expect(project_b.managers).not_to include(another_user, user3, user4)
          end
          it 'creates a flash message with the user name' do
            expect(flash[:error]).to match(user_status_message)
          end
        end

        context 'all team members are contributors' do
          before do
            all_users.each do |user|
              is_contributor(user)
            end
          end
          it 'adds the other team members to subcollection managers' do
            post :update_collection_groups, params: params
            expect(team.managers).to match_array(all_users)
            expect(project_a.managers).to match_array(all_users)
            expect(project_b.managers).to match_array(all_users)
          end
        end
      end

      context 'manager adds another team to depositors access' do
        let(:params)          { { collection_roles: { agent_type: 'group', access: '', team_collection_id: team2.id }, id: team.id } }
        let(:team_2_members)  { [another_user, user3, user4] }
        let(:all_users)       { [manager, another_user, user3, user4] }

        before do
          set_access_params('depositors')
          allow(subject).to receive(:can?).with(:edit, team).and_return(true)
          allow(subject).to receive(:can?).with(:edit, team2).and_return(true)
          allow(team2).to receive(:group_members).and_return(team_2_members)
        end

        context 'one of the other team members is not a contributor' do
          before do
            is_not_contributor(another_user)
            post :update_collection_groups, params: params
          end
          it 'does not add the other team members to subcollection managers' do
            expect(team.depositors).not_to include(another_user, user3, user4)
            expect(project_a.depositors).not_to include(another_user, user3, user4)
            expect(project_b.depositors).not_to include(another_user, user3, user4)
          end
          it 'creates a flash message with the user name' do
            expect(flash[:error]).to match(user_status_message)
          end
        end

        context 'all the team members are contributors' do
          before do
            team_2_members.each do |member|
              is_contributor(member)
            end
          end
          it 'adds the other team members to subcollection managers' do
            post :update_collection_groups, params: params
            expect(team.depositors).to match_array(team_2_members)
            expect(project_a.depositors).to match_array(team_2_members)
            expect(project_b.depositors).to match_array(team_2_members)
          end
        end
      end

      context 'manager adds another team to viewers access' do
        let(:params)          { { collection_roles: { agent_type: 'group', access: '', team_collection_id: team2.id }, id: team.id } }
        let(:team_2_members)  { [another_user, user3, user4] }
        let(:all_users)       { [manager, another_user, user3, user4] }

        before do
          set_access_params('viewers')
          allow(subject).to receive(:can?).with(:edit, team).and_return(true)
          allow(subject).to receive(:can?).with(:edit, team2).and_return(true)
          allow(team2).to receive(:group_members).and_return(team_2_members)
        end

        it 'adds the other team members to subcollection managers' do
          post :update_collection_groups, params: params
          expect(team.viewers).to match_array(team_2_members)
          expect(project_a.viewers).to match_array(team_2_members)
          expect(project_b.viewers).to match_array(team_2_members)
        end
      end

      context 'manager adds another team to depositors access, the subcollections already have users from the other team in access roles' do
        let(:params)          { { collection_roles: { agent_type: 'group', access: '', team_collection_id: team2.id }, id: team.id } }
        let(:team_2_members)  { [another_user, user3, user4] }
        let(:all_users)       { [manager, another_user, user3, user4] }

        before do
          set_access_params('depositors')
          allow(subject).to receive(:can?).with(:edit, team).and_return(true)
          allow(subject).to receive(:can?).with(:edit, team2).and_return(true)
          allow(team2).to receive(:group_members).and_return(team_2_members)
          project_a.managers << user3 << user4
          project_a.managers_group.save
          project_b.viewers << user3 << user4
          project_b.viewers_group.save
        end

        context 'one of the team members is not a contributor' do
          before do
            is_not_contributor(another_user)
            post :update_collection_groups, params: params
          end
          it 'does not add the other team members to subcollection depositors, and does not remove their previous access roles' do
            expect(team.depositors).not_to include(another_user, user3, user4)
            expect(project_a.depositors).not_to include(another_user, user3, user4)
            expect(project_a.managers).to include(user3, user4)
            expect(project_b.depositors).not_to include(another_user, user3, user4)
            expect(project_b.viewers).to include(user3, user4)
          end
          it 'creates a flash message with the user name' do
            expect(flash[:error]).to match(user_status_message)
          end
        end
        context 'all of the team members are contributors' do
          before do
            team_2_members.each do |member|
              is_contributor(member)
            end
          end
          it 'adds the other team members to subcollection depositors, and removes their previous access roles' do
            post :update_collection_groups, params: params
            expect(team.depositors).to include(user3, user4)
            expect(project_a.depositors).to include(user3, user4)
            expect(project_a.managers).not_to include(user3, user4)
            expect(project_b.depositors).to include(user3, user4)
            expect(project_b.viewers).not_to include(user3, user4)
          end
        end
      end
    end

    describe 'update_collection_managed_date' do
      before do
        allow(subject).to receive(:users_are_eligible?).and_return(true)
        allow(subject).to receive(:update_subcollections).and_return(true)
        allow(subject).to receive(:removing_last_manager?).and_return(false)
        Timecop.freeze(Time.local(1999, 9, 9, 9))
      end

      after do
        Timecop.return
      end

      context 'organization is a collection' do
        let(:params)        { { collection_roles: { agent_type: 'user', remove: 'false', access: 'managers', agent_id: manager.ms_id }, id: organization.id } }
        let(:organization)  { FactoryBot.create(:organization_collection, title: ['Organization'], depositor: manager.ms_id) }

        before do
          allow(subject).to receive(:can?).with(:edit, organization).and_return(true)
        end

        it 'is called by update_collection_groups' do
          allow(subject).to receive(:collection_role_values).and_return(true)
          allow(subject).to receive(:update_agent_access).and_return(true)

          expect(subject).to receive(:update_collection_managed_date)
          post :update_collection_groups, params: { id: organization.id }
        end

        context 'adding a manager for the first time' do
          it 'updates the organization date_managed' do
            expect { post :update_collection_groups, params: params }.to change(organization, :date_managed).from(nil).to(Date.today)
          end
        end

        context 'adding additional managers' do
          before do
            organization.managers << another_user
            organization.managers_group.save
            organization.date_managed = Date.yesterday
            organization.save
          end

          it 'does not update the organization date managed' do
            expect { post :update_collection_groups, params: params }.not_to change(organization, :date_managed)
          end
        end

        context 'removing all managers from the collection' do
          let(:params)  { { collection_roles: { agent_type: 'user', new_access: 'remove', access: 'managers', agent_id: another_user.ms_id }, id: organization.id } }

          before do
            organization.managers << another_user
            organization.managers_group.save
            organization.date_managed = Date.yesterday
            organization.save
          end

          it 'sets date_managed as nil' do
            expect { post :update_collection_groups, params: params }.to change(organization, :date_managed).from(Date.yesterday).to(nil)
          end
        end
      end

      context 'organization is a work' do
        let!(:team)         { FactoryBot.create(:team, title: ['Team'], depositor: manager.ms_id) }
        let!(:organization) { FactoryBot.create(:organization, title: ['Organization'], team_id: [team.id], depositor: manager.ms_id) }
        let(:params)        { { collection_roles: { agent_type: 'user', remove: 'false', access: 'managers', agent_id: manager.ms_id }, id: team.id } }

        before do
          allow(subject).to receive(:can?).with(:edit, team).and_return(true)
          allow(team).to receive(:organization).and_return(organization)
          team.create_collection_groups
          team.managers_group.users = []
          team.managers_group.save!
        end

        it 'is called by update_collection_groups' do
          allow(subject).to receive(:collection_role_values).and_return(true)
          allow(subject).to receive(:update_agent_access).and_return(true)

          expect(subject).to receive(:update_collection_managed_date)
          post :update_collection_groups, params: { id: team.id }
        end

        context 'adding a manager for the first time' do
          before do
            organization.date_managed = nil
            organization.save!
          end

          it 'updates the organization date_managed' do
            expect { post :update_collection_groups, params: params }.to change(organization, :date_managed).from(nil).to(Date.today)
          end
        end

        context 'adding additional managers' do
          before do
            team.managers << manager
            team.managers_group.save
            organization.date_managed = Date.yesterday
            organization.save
          end

          it 'does not update the organization date managed' do
            expect { post :update_collection_groups, params: params }.not_to change(organization, :date_managed)
          end
        end

        context 'removing all managers from the collection' do
          let(:params)  { { collection_roles: { agent_type: 'user', new_access: 'remove', access: 'managers', agent_id: manager.ms_id }, id: team.id } }

          before do
            team.managers << manager
            team.managers_group.save
            organization.date_managed = Date.yesterday
            organization.save!
          end

          it 'sets date_managed as nil' do
            expect { post :update_collection_groups, params: params }.to change(organization, :date_managed).from(Date.yesterday).to(nil)
          end
        end

      end
    end

    describe 'maybe_update_org_cart_item_reviewers' do
      let(:org) { FactoryBot.create(:organization_collection, title: ['Org'], depositor: manager.ms_id) }

      before do
        allow(subject).to receive(:users_are_eligible?).and_return(true)
        allow(subject).to receive(:update_subcollections).and_return(true)
        allow(subject).to receive(:removing_last_manager?).and_return(false)
      end

      context 'collection is an OrganizationCollection with no download_reviewer' do
        before do
          allow(subject).to receive(:can?).with(:edit, org).and_return(true)
        end

        context 'adding a user to the managers group' do
          let(:params) { { collection_roles: { agent_type: 'user', remove: 'false', access: 'managers', agent_id: another_user.ms_id }, id: org.id } }

          it 'enqueues UpdateOrgCartItemReviewersJob' do
            expect(UpdateOrgCartItemReviewersJob).to receive(:perform_later).with(org)
            post :update_collection_groups, params: params
          end
        end

        context 'removing a user from the managers group' do
          let(:params) { { collection_roles: { agent_type: 'user', new_access: 'remove', access: 'managers', agent_id: another_user.ms_id }, id: org.id } }

          before do
            org.managers << another_user
            org.managers_group.save
          end

          it 'enqueues UpdateOrgCartItemReviewersJob' do
            expect(UpdateOrgCartItemReviewersJob).to receive(:perform_later).with(org)
            post :update_collection_groups, params: params
          end
        end

        context 'moving a user from viewers to managers' do
          let(:params) { { collection_roles: { agent_type: 'user', access: 'viewers', new_access: 'managers', agent_id: another_user.ms_id }, id: org.id } }

          before do
            org.viewers << another_user
            org.viewers_group.save
          end

          it 'enqueues UpdateOrgCartItemReviewersJob' do
            expect(UpdateOrgCartItemReviewersJob).to receive(:perform_later).with(org)
            post :update_collection_groups, params: params
          end
        end

        context 'adding a user to a non-managers group' do
          let(:params) { { collection_roles: { agent_type: 'user', remove: 'false', access: 'viewers', agent_id: another_user.ms_id }, id: org.id } }

          it 'does not enqueue UpdateOrgCartItemReviewersJob' do
            expect(UpdateOrgCartItemReviewersJob).not_to receive(:perform_later)
            post :update_collection_groups, params: params
          end
        end
      end

      context 'collection is an OrganizationCollection with download_reviewer configured' do
        let(:params) { { collection_roles: { agent_type: 'user', remove: 'false', access: 'managers', agent_id: another_user.ms_id }, id: org.id } }

        before do
          allow(subject).to receive(:can?).with(:edit, org).and_return(true)
          org.download_reviewer = [manager.ms_id]
          org.save!
        end

        it 'does not enqueue UpdateOrgCartItemReviewersJob' do
          expect(UpdateOrgCartItemReviewersJob).not_to receive(:perform_later)
          post :update_collection_groups, params: params
        end
      end

      context 'collection is not an OrganizationCollection' do
        let(:params) { { collection_roles: { agent_type: 'user', remove: 'false', access: 'managers', agent_id: another_user.ms_id }, id: team.id } }

        before do
          allow(subject).to receive(:can?).with(:edit, team).and_return(true)
        end

        it 'does not enqueue UpdateOrgCartItemReviewersJob' do
          expect(UpdateOrgCartItemReviewersJob).not_to receive(:perform_later)
          post :update_collection_groups, params: params
        end
      end
    end
  end

  # test helper methods
  def set_access_params(access)
    params[:collection_roles][:access] = access
  end

  def set_new_access_params(access)
    params[:collection_roles][:new_access] = access
  end
end