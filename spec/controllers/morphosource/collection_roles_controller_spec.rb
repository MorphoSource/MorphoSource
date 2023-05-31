# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionRolesController, type: :controller do
  let(:manager)                 { User.create(email: 'test@test.com', password: 'password') }
  let(:another_user)            { User.create(email: 'email@email.com', password: 'password') }
  let(:team_collection_type)    { Hyrax::CollectionType.create(title: 'Team', machine_id: 'team') }
  let(:project_collection_type) { Hyrax::CollectionType.create(title: 'Project', machine_id: 'project') }
  let!(:media_list_collection_type)    { Hyrax::CollectionType.create(title: 'Media List', machine_id: 'media_list') }
  let!(:sequential_section_list_collection_type)  { Hyrax::CollectionType.create(title: 'Sequential Section List', machine_id: 'sequential_section_list') }
  let(:team)                    { Collection.create(title: ['Team_A'], collection_type_gid: team_collection_type.gid, depositor: manager.ms_id) }
  let(:team2)                   { Collection.create(title: ['Team_A'], collection_type_gid: team_collection_type.gid, depositor: another_user.ms_id) }
  let(:project)                 { Collection.create(title: ['Project'], collection_type_gid: project_collection_type.gid, depositor: manager.ms_id) }
  let(:media_list)              { MediaList.create(title: ['Media List'], collection_type_gid: media_list_collection_type.gid, depositor: manager.ms_id) }
  let(:sequential_section_list) { SequentialSectionList.create(title: ['Sequential Section List'], collection_type_gid: sequential_section_list_collection_type.gid, depositor: manager.ms_id) }


  before do
    allow(Collection).to receive(:find).with(team.id).and_return(team)
    allow(Collection).to receive(:find).with(team2.id).and_return(team2)
    allow(Collection).to receive(:find).with(project.id).and_return(project)
    allow(Collection).to receive(:find).with(media_list.id).and_return(media_list)
    allow(Collection).to receive(:find).with(sequential_section_list.id).and_return(sequential_section_list)
    allow(User).to receive(:find_by).with(ms_id: another_user.ms_id).and_return(another_user)
    allow(User).to receive(:find_by).with(ms_id: manager.ms_id).and_return(manager)

    sign_in manager
  end

  describe '#update_collection_groups' do
  let(:user_status_message) { "The user (#{another_user.email}) can't be added to the #{params[:collection_roles][:access]} role because they do not have contributor status. Either add the user to a membership role that does not require contributor status (downloader, viewer) or have the user request contributor status." }
    before do
      team.create_collection_groups
    end
    context 'current_user is not a collection manager' do
      before do
        allow(subject).to receive(:can?).with(:edit, team).and_return(false)
        allow(subject).to receive(:can?).with(:edit, media_list).and_return(false)
      end
      let(:team_params) { { collection_roles: { agent_type: 'user', remove: 'false', access: 'managers', agent_id: another_user.ms_id }, id: team.id } }
      let(:list_params) { { collection_roles: { agent_type: 'user', remove: 'false', access: 'managers', agent_id: another_user.ms_id }, id: media_list.id } }

      it 'does not update the team collection groups' do
        expect { process :update_collection_groups, method: :post, params: team_params }.not_to change { team.group_members.count }
      end
      it 'does not update the list collection groups' do
        expect { process :update_collection_groups, method: :post, params: list_params }.not_to change { media_list.group_members.count }
      end
    end

    context 'adding an individual user' do
      let(:params) { { collection_roles: { agent_type: 'user', remove: 'false', access: '', agent_id: another_user.ms_id }, id: team.id } }
      before do
        set_access_params('managers')
        allow(subject).to receive(:update_subcollections).and_return(true)
        allow(subject).to receive(:can?).with(:edit, team).and_return(true)
        allow(subject).to receive(:can?).with(:edit, media_list).and_return(true)
      end

      context 'user already has a role in the collection' do
        context 'collection is a team' do
          before do
            is_contributor(another_user)
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
        context 'collection is a list' do
          before do
            is_contributor(another_user)
            params[:id] = media_list.id
            set_access_params('managers')
            media_list.viewers << another_user
            media_list.viewers_group.save
            post :update_collection_groups, params: params
          end
          it "does not add the user to the collection's manager role" do
            expect(media_list.managers).to match_array([manager])
          end
          it 'creates a flash message with the user name' do
            expect(flash[:error]).to match("#{another_user.name} is already a member of #{media_list.title.first}")
          end
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
          context 'collection is a team' do
            it "adds the user to the collection's manager role" do
              post :update_collection_groups, params: params
              expect(team.managers).to include(another_user)
            end
          end
          context 'collection is a list' do
            before do
              params[:id] = media_list.id
            end
            it "adds the user to the collection's manager role" do
              post :update_collection_groups, params: params
              expect(media_list.managers).to match_array([manager, another_user])
            end
          end
        end

        context 'user is not a contributor' do
          before do
            is_not_contributor(another_user)
            post :update_collection_groups, params: params
          end
          context 'collection is a team' do
            it "does not add the user to the collection's manager role" do
              expect(team.managers).not_to include(another_user)
            end
            it 'creates a flash message with the user name' do
              expect(flash[:error]).to match(user_status_message)
            end
          end
          context 'collection is a list' do
            before do
              params[:id] = media_list.id
            end
            it "does not add the user to the collection's manager role" do
              expect(media_list.managers).to match_array([manager])
            end
            it 'creates a flash message with the user name' do
              expect(flash[:error]).to match(user_status_message)
            end
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
        context 'collection is a team' do
          it "adds the user to the collection's viewer role" do
            post :update_collection_groups, params: params
            expect(team.viewers).to include(another_user)
          end
        end
        context 'collection is a list' do
          before do
            params[:id] = media_list.id
          end
          it "adds the user to the collection's viewer role" do
            post :update_collection_groups, params: params
            expect(media_list.viewers).to match_array([another_user])
          end
        end
      end

      context 'the user already has a role in the collection' do
        context 'collection is a team' do
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
        context 'collection is a list' do
          before do
            params[:id] = media_list.id
            set_access_params('viewers')
            params[:collection_roles][:agent_id] = manager.ms_id
            is_contributor(manager)
          end
          it "does not add the user to the collection's group members" do
            post :update_collection_groups, params: params
            expect(media_list.viewers).not_to include(manager)
          end
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
        allow(subject).to receive(:can?).with(:edit, media_list).and_return(true)
        allow(subject).to receive(:update_subcollections).and_return(true)
      end

      context 'manager removes another user as a manager' do
        before do
          set_access_params('managers')
        end
        context 'collection is a team' do
          it 'removes the user from the managers group' do
            post :update_collection_groups, params: params
            expect(team.managers).not_to include(another_user)
          end
        end
        context 'collection is a list' do
          before do
            params[:id] = media_list.id
          end
          it 'removes the user from the managers group' do
            post :update_collection_groups, params: params
            expect(media_list.managers).not_to include(another_user)
          end
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
        context 'collection is a team' do
          it 'removes the user from the viewers group' do
            post :update_collection_groups, params: params
            expect(team.viewers).not_to include(another_user)
          end
        end
        context 'collection is a list' do
          before do
            params[:id] = media_list.id
          end
          it 'removes the user from the viewers group' do
            post :update_collection_groups, params: params
            expect(media_list.viewers).not_to include(another_user)
          end
        end

      end
    end

    context 'moving users to different roles' do
      let(:params) { { collection_roles: { agent_type: 'user', new_access: '', access: '', agent_id: another_user.ms_id }, id: team.id } }
      before do
        allow(subject).to receive(:can?).with(:edit, team).and_return(true)
        allow(subject).to receive(:can?).with(:edit, media_list).and_return(true)
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
        end
        context 'collection is a team' do
          before do
            team.managers_group.users << another_user
            team.save
          end
          it 'moves the user to the correct group' do
            post :update_collection_groups, params: params
            expect(team.managers).not_to include(another_user)
            expect(team.viewers).to include(another_user)
          end
        end
        context 'collection is a list' do
          before do
            params[:id] = media_list.id
            media_list.managers_group.users << another_user
            media_list.save
          end
          it 'moves the user to the correct group' do
            post :update_collection_groups, params: params
            expect(media_list.managers).not_to include(another_user)
            expect(media_list.viewers).to include(another_user)
          end
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
          media_list.viewers_group.users << another_user
          media_list.save
        end
        context 'user is not a contributor' do
          before do
            is_not_contributor(another_user)
            post :update_collection_groups, params: params
          end
          context 'collection is a team' do
            it 'does not move the user to the new group' do
              expect(team.viewers).to include(another_user)
              expect(team.managers).not_to include(another_user)
            end
            it 'creates a flash message with the user name' do
              expect(flash[:error]).to match(user_status_message)
            end
          end
          context 'collection is a list' do
            before do
              params[:id] = media_list.id
            end
            it 'does not move the user to the new group' do
              expect(media_list.viewers).to include(another_user)
              expect(media_list.managers).not_to include(another_user)
            end
            it 'creates a flash message with the user name' do
              expect(flash[:error]).to match(user_status_message)
            end
          end
        end
        context 'user is a contributor' do
          before do
            is_contributor(another_user)
          end
          context 'collection is a team' do
            it 'moves the user to the correct group' do
              post :update_collection_groups, params: params
              expect(team.viewers).not_to include(another_user)
              expect(team.managers).to include(another_user)
            end
          end
          context 'collection is a list' do
            before do
              params[:id] = media_list.id
            end
            it 'moves the user to the correct group' do
              post :update_collection_groups, params: params
              expect(media_list.viewers).not_to include(another_user)
              expect(media_list.managers).to include(another_user)
            end
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
      let(:user3)   { User.create(email: 'blah@blah.com', password: 'password') }

      before do
        allow(subject).to receive(:can?).with(:edit, team).and_return(true)
        allow(subject).to receive(:can?).with(:edit, team2).and_return(true)
        allow(subject).to receive(:can?).with(:edit, media_list).and_return(true)
        allow(team2).to receive(:group_members).and_return([another_user, user3])
        allow(subject).to receive(:update_subcollections).and_return(true)
        team2.create_collection_groups
      end

      context 'collection manager does not manage the other team' do
        before do
          allow(subject).to receive(:can?).with(:edit, team2).and_return(false)
          set_access_params('viewers')
        end
        context 'collection is a team' do
          it "does not add the other team's members to the collection" do
            post :update_collection_groups, params: params
            expect(team.viewers).not_to include(another_user, user3)
          end
        end
        context 'collection is a list' do
          before do
            params[:id] = media_list.id
          end
          it "does not add the other team's members to the collection" do
            post :update_collection_groups, params: params
            expect(media_list.viewers).not_to include(another_user, user3)
          end
        end
      end

      context 'manager adds another team as a managers' do
        before do
          set_access_params('managers')
        end
        context 'one of the team members is not a contributor' do
          before do
            is_not_contributor(another_user)
            is_contributor(user3)
          end
          context 'collection is a team' do
            before do
              post :update_collection_groups, params: params
            end
            it "does not add the other team's members to the collection" do
              expect(team.managers).not_to include(another_user, user3)
            end
            it 'creates a flash message with the user name' do
              expect(flash[:error]).to match(user_status_message)
            end
          end
          context 'collection is a list' do
            let(:user_status_message) {"The user (#{another_user.email}) can't be added to the #{params[:collection_roles][:access]} role because they do not have contributor status. Either add the user to a membership role that does not require contributor status (viewer) or have the user request contributor status."}
            before do
              params[:id] = media_list.id
              post :update_collection_groups, params: params
            end
            it "does not add the other team's members to the collection" do
              expect(media_list.managers).not_to include(another_user, user3)
            end
            it 'creates a flash message with the user name' do
              expect(flash[:error]).to match(user_status_message)
            end
          end
        end
        context 'all the team members are contributors' do
          before do
            is_contributor(another_user)
            is_contributor(user3)
          end
          context 'collection is a team' do
            it "adds the other team's members to the collection" do
              post :update_collection_groups, params: params
              expect(team.managers).to include(another_user, user3)
            end
          end
          context 'collection is a list' do
            before do
              params[:id] = media_list.id
              post :update_collection_groups, params: params
            end
            it "adds the other team's members to the collection" do
              post :update_collection_groups, params: params
              expect(media_list.managers).to include(another_user, user3)
            end
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
            is_contributor(user3)
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
            is_contributor(user3)
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
        context 'collection is a team' do
          it "adds the other team's members to the collection" do
            post :update_collection_groups, params: params
            expect(team.viewers).to include(another_user, user3)
          end
        end
        context 'collection is a list' do
          before do
            params[:id] = media_list.id
          end
          it "adds the other team's members to the collection" do
            post :update_collection_groups, params: params
            expect(media_list.viewers).to include(another_user, user3)
          end
        end
      end

      context 'some team members already have a collection role' do
        before do
          set_access_params('viewers')
        end
        context 'collection is a team' do
          before do
            allow(team).to receive(:group_members).and_return([manager, another_user])
          end
          it "adds only the other team's members that don't already belong to the collection's group members to the collection" do
            post :update_collection_groups, params: params
            expect(team.viewers).to include(user3)
            expect(team.viewers).not_to include(another_user)
          end
        end
        context 'collection is a list' do
          before do
            allow(media_list).to receive(:group_members).and_return([manager, another_user])
            params[:id] = media_list.id
          end
          it "adds only the other team's members that don't already belong to the collection's group members to the collection" do
            post :update_collection_groups, params: params
            expect(media_list.viewers).to include(user3)
            expect(media_list.viewers).not_to include(another_user)
          end
        end
      end
    end

    context 'team has subcollections' do
      let(:project_collection_type) { Hyrax::CollectionType.create(title: 'Project', machine_id: 99) }
      let(:project_a) { Collection.create(title: ['Project_A'], collection_type_gid: project_collection_type.gid, depositor: manager.ms_id) }
      let(:project_b) { Collection.create(title: ['Project_B'], collection_type_gid: project_collection_type.gid, depositor: manager.ms_id) }

      let(:projects_solr) { [SolrDocument.new(project_a.to_solr), SolrDocument.new(project_b.to_solr)] }

      let(:params) { { collection_roles: { agent_type: 'user', remove: 'false', access: '', agent_id: another_user.ms_id }, id: team.id } }

      before do
        project_a.create_collection_groups
        project_b.create_collection_groups
        allow(subject).to receive(:can?).with(:edit, team).and_return(true)
        allow(subject).to receive(:find_subcollections).and_return(true)
        subject.instance_variable_set(:@subcollection_docs, projects_solr)
        allow(Collection).to receive(:find).with(project_a.id).and_return(project_a)
        allow(Collection).to receive(:find).with(project_b.id).and_return(project_b)
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
        let(:params)  { { collection_roles: { agent_type: 'group', access: '', team_collection_id: team2.id }, id: team.id } }
        let(:user3)   { User.create(email: 'blah@blah.com', password: 'password') }
        let(:user4)   { User.create(email: 'user4@email.com', password: 'password') }
        let(:team_2_members) { [another_user, user3, user4] }
        let(:all_users) { [manager, another_user, user3, user4] }

        before do
          set_access_params('managers')
          allow(subject).to receive(:can?).with(:edit, team).and_return(true)
          allow(subject).to receive(:can?).with(:edit, team2).and_return(true)
          allow(team2).to receive(:group_members).and_return(team_2_members)
        end

        context 'one team member is not a contributor' do
          before do
            is_not_contributor(another_user)
            is_contributor(user3)
            is_contributor(user4)
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
        let(:params)  { { collection_roles: { agent_type: 'group', access: '', team_collection_id: team2.id }, id: team.id } }
        let(:user3)   { User.create(email: 'blah@blah.com', password: 'password') }
        let(:user4)   { User.create(email: 'user4@email.com', password: 'password') }
        let(:team_2_members) { [another_user, user3, user4] }
        let(:all_users) { [manager, another_user, user3, user4] }

        before do
          set_access_params('depositors')
          allow(subject).to receive(:can?).with(:edit, team).and_return(true)
          allow(subject).to receive(:can?).with(:edit, team2).and_return(true)
          allow(team2).to receive(:group_members).and_return(team_2_members)
        end

        context 'one of the other team members is not a contributor' do
          before do
            is_not_contributor(another_user)
            is_contributor(user3)
            is_contributor(user4)
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
        let(:params)  { { collection_roles: { agent_type: 'group', access: '', team_collection_id: team2.id }, id: team.id } }
        let(:user3)   { User.create(email: 'blah@blah.com', password: 'password') }
        let(:user4)   { User.create(email: 'user4@email.com', password: 'password') }
        let(:team_2_members) { [another_user, user3, user4] }
        let(:all_users) { [manager, another_user, user3, user4] }

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
        let(:params)  { { collection_roles: { agent_type: 'group', access: '', team_collection_id: team2.id }, id: team.id } }
        let(:user3)   { User.create(email: 'blah@blah.com', password: 'password') }
        let(:user4)   { User.create(email: 'user4@email.com', password: 'password') }
        let(:team_2_members) { [another_user, user3, user4] }
        let(:all_users) { [manager, another_user, user3, user4] }

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
            is_contributor(user3)
            is_contributor(user4)
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
  end

  describe 'presenter' do
    context 'collection is a team' do
      before do
        set_collection(team)
      end
      it 'is TeamPresenter' do
        expect(subject.send(:presenter).class).to eq(Morphosource::Collections::TeamPresenter)
      end
    end
    context 'collection is a project' do
      before do
        set_collection(project)
      end
      it 'is ProjectPresenter' do
        expect(subject.send(:presenter).class).to eq(Morphosource::Collections::ProjectPresenter)
      end
    end
    context 'collection is a media list' do
      before do
        set_collection(media_list)
      end
      it 'is MediaListPresenter' do
        expect(subject.send(:presenter).class).to eq(Morphosource::Collections::MediaListPresenter)
      end
    end
    context 'collection is a sequential section list' do
      before do
        set_collection(sequential_section_list)
      end
      it 'is MediaListPresenter' do
        expect(subject.send(:presenter).class).to eq(Morphosource::Collections::MediaLists::SequentialSectionListPresenter)
      end
    end
  end

  # test helper methods
  def is_contributor(user)
    allow(user).to receive(:contributor?).and_return(true)
  end

  def is_not_contributor(user)
    allow(user).to receive(:contributor?).and_return(false)
  end

  def set_access_params(access)
    params[:collection_roles][:access] = access
  end

  def set_new_access_params(access)
    params[:collection_roles][:new_access] = access
  end

  def set_collection(collection)
    collection.create_collection_groups
    collection.read_users += [manager]
    collection.save!
    subject.instance_variable_set(:@collection, collection)
    subject.instance_variable_set(:@curation_concern, collection)
  end
end
