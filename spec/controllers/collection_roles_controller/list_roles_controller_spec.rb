# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionRolesController, type: :controller do

  include TestHelpers

  let(:manager)                 { FactoryBot.create(:contributor) }
  let(:another_user)            { FactoryBot.create(:contributor) }
  let(:user3)                   { FactoryBot.create(:contributor) }
  let(:user4)                   { FactoryBot.create(:contributor) }
  let(:media_list)              { FactoryBot.create(:media_list, depositor: manager.ms_id) }

  let(:user_status_message) { "The user (#{another_user.email}) can't be added to the #{params[:collection_roles][:access]} role because they do not have contributor status. Either add the user to a membership role that does not require contributor status (downloader, viewer) or have the user request contributor status." }

  before do
    sign_in manager
  end

  describe '#update_collection_groups' do
    before do
      media_list.create_collection_groups
    end
    context 'current_user is not a collection manager' do
      before do
        allow(subject).to receive(:can?).with(:edit, media_list).and_return(false)
      end
      let(:params) { { collection_roles: { agent_type: 'user', remove: 'false', access: 'managers', agent_id: another_user.ms_id }, id: media_list.id } }

      it 'does not update the collection groups' do
        expect { process :update_collection_groups, method: :post, params: params }.not_to change { media_list.group_members.count }
      end
    end

    context 'adding an individual user' do
      let(:params) { { collection_roles: { agent_type: 'user', remove: 'false', access: '', agent_id: another_user.ms_id }, id: media_list.id } }
      before do
        allow(subject).to receive(:can?).with(:edit, media_list).and_return(true)
        allow(subject).to receive(:update_subcollections).and_return(true)
      end

      context 'user already has a role in the collection' do
        before do
          set_access_params('managers')
          media_list.viewers << another_user
          media_list.viewers_group.save
          post :update_collection_groups, params: params
        end
        it "does not add the user to the collection's manager role" do
          expect(media_list.managers).not_to include(another_user)
        end
        it 'creates a flash message with the user name' do
          expect(flash[:error]).to match("#{another_user.name} is already a member of #{media_list.title.first}")
        end
      end

      context 'manager adds another user as a manager' do
        before do
          set_access_params('managers')
        end

        context 'user is a contributor' do
          it "adds the user to the collection's manager role" do
            post :update_collection_groups, params: params
            expect(media_list.managers).to include(another_user)
          end
        end

        context 'user is not a contributor' do
          it "adds the user to the collection's manager role" do
            is_not_contributor(another_user)
            post :update_collection_groups, params: params
            expect(media_list.managers).to include(another_user)
          end
        end
      end

      context 'manager adds another user as a viewer' do
        before do
          set_access_params('viewers')
        end
        it "adds the user to the collection's viewer role" do
          post :update_collection_groups, params: params
          expect(media_list.viewers).to include(another_user)
        end
      end

      context 'the user already has a role in the collection' do
        before do
          set_access_params('viewers')
          params[:collection_roles][:agent_id] = manager.ms_id
        end
        it "does not add the user to the collection's group members" do
          post :update_collection_groups, params: params
          expect(media_list.viewers).not_to include(manager)
        end
      end
    end

    context 'removing an individual user' do
      let(:params) { { collection_roles: { agent_type: 'user', new_access: 'remove', access: '', agent_id: another_user.ms_id }, id: media_list.id } }
      before do
        media_list.user_groups.each do |group|
          group.users << another_user
          group.save
        end
        allow(subject).to receive(:can?).with(:edit, media_list).and_return(true)
        allow(subject).to receive(:update_subcollections).and_return(true)
      end

      context 'manager removes another user as a manager' do
        before do
          set_access_params('managers')
        end
        it 'removes the user from the managers group' do
          post :update_collection_groups, params: params
          expect(media_list.managers).not_to include(another_user)
        end
      end

      context 'manager removes another user as a viewer' do
        before do
          set_access_params('viewers')
        end
        it 'removes the user from the viewers group' do
          post :update_collection_groups, params: params
          expect(media_list.viewers).not_to include(another_user)
        end
      end
    end

    context 'moving users to different roles' do
      let(:params) { { collection_roles: { agent_type: 'user', new_access: '', access: '', agent_id: another_user.ms_id }, id: media_list.id } }
      before do
        allow(subject).to receive(:can?).with(:edit, media_list).and_return(true)
        allow(subject).to receive(:update_subcollections).and_return(true)
      end
      context 'manager moves a user from manager to viewer' do
        before do
          set_access_params('managers')
          set_new_access_params('viewers')
          media_list.managers_group.users << another_user
          media_list.save
        end
        it 'moves the user to the correct group' do
          post :update_collection_groups, params: params
          expect(media_list.managers).not_to include(another_user)
          expect(media_list.viewers).to include(another_user)
        end
      end
      context 'manager moves a user from viewer to manager' do
        before do
          set_access_params('viewers')
          set_new_access_params('managers')
          media_list.viewers_group.users << another_user
          media_list.save
        end
        context 'user is not a contributor' do
          it 'moves the user to the correct group' do
            is_not_contributor(another_user)
            post :update_collection_groups, params: params
            expect(media_list.viewers).not_to include(another_user)
            expect(media_list.managers).to include(another_user)
          end
        end
        context 'user is a contributor' do
          it 'moves the user to the correct group' do
            post :update_collection_groups, params: params
            expect(media_list.viewers).not_to include(another_user)
            expect(media_list.managers).to include(another_user)
          end
        end
      end
    end

    context 'adding another team' do
      let(:team)    { FactoryBot.create(:team, title: ['Team'], depositor: manager.ms_id) }
      let(:params)  { { collection_roles: { agent_type: 'group', access: '', team_collection_id: team.id }, id: media_list.id } }

      before do
        allow(subject).to receive(:can?).with(:edit, media_list).and_return(true)
        allow(subject).to receive(:can?).with(:edit, team).and_return(true)
        allow(team).to receive(:group_members).and_return([another_user, user3])
        allow(subject).to receive(:update_subcollections).and_return(true)
        team.create_collection_groups
      end

      context 'collection manager does not manage the other team' do
        before do
          allow(subject).to receive(:can?).with(:edit, team).and_return(false)
          set_access_params('viewers')
        end
        it "does not add the other team's members to the collection" do
          post :update_collection_groups, params: params
          expect(media_list.viewers).not_to include(another_user, user3)
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
          it "adds the other team's members to the collection" do
            expect(media_list.managers).to include(another_user, user3)
          end
        end
        context 'all the team members are contributors' do
          it "adds the other team's members to the collection" do
            post :update_collection_groups, params: params
            expect(media_list.managers).to include(another_user, user3)
          end
        end
      end

      context 'manager adds another team as a viewers' do
        before do
          set_access_params('viewers')
        end
        it "adds the other team's members to the collection" do
          post :update_collection_groups, params: params
          expect(media_list.viewers).to include(another_user, user3)
        end
      end

      context 'some team members already have a collection role' do
        before do
          set_access_params('viewers')
          allow(media_list).to receive(:group_members).and_return([manager, another_user])
        end
        it "adds only the other team's members that don't already belong to the collection's group members to the collection" do
          post :update_collection_groups, params: params
          expect(media_list.viewers).to include(user3)
          expect(media_list.viewers).not_to include(another_user)
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