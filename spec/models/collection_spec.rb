# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collection, type: :model do
  let(:team_collection_type) { Hyrax::CollectionType.create(title: 'Team', machine_id: 88) }
  let(:project_collection_type) { Hyrax::CollectionType.create(title: 'Project', machine_id: 77) }
  let(:another_collection_type) { Hyrax::CollectionType.create(title: 'Another', machine_id: 99) }
  let(:user) { User.create(email: 'email@email.com', password: 'password', ms_id: 'abc123') }

  let(:team) { Collection.create(title: ['Team_B'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id) }

  let(:project) { Collection.create(title: ['Project_B'], collection_type_gid: project_collection_type.gid, depositor: user.ms_id) }

  before do
    allow(User).to receive(:find_by).with(ms_id: user.ms_id).and_return(user)
  end

  describe '#organization' do
    let!(:org1)  { Organization.create(title: ['title'], team_id: [team.id]) }
    let!(:org2)  { Organization.create(title: ['title'], team_id: []) }
    let!(:org3)  { Organization.create(title: ['title'], team_id: []) }

    it 'returns the organization linked to the team' do
      expect(team.organization).to eq(org1)
    end
  end

  describe '#create_collection_groups' do

    it 'creates manager, depositor, and viewer groups' do
      expect { team.create_collection_groups }.to change { Role.count }.by(3)
    end

    it 'assigns them names with the collection id' do
      team.create_collection_groups
      group_names = Role.all.map(&:name)
      Collection::DEFAULT_GROUP_ROLES.each do |role|
        expect(group_names).to include("#{team.id}_#{role}")
      end
    end

    it 'adds the depositor to the managers group' do
      team.create_collection_groups
      expect(team.managers).to include(user)
    end
  end

  describe '#copy_parent_membership' do
    let(:parent) { Collection.create(title: ['Parent'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id) }
    let(:parent_manager) { User.create(email: 'manager@email.com', password: 'password') }
    let(:parent_depositor) { User.create(email: 'depositor@email.com', password: 'password') }
    let(:parent_viewer) { User.create(email: 'viewer@email.com', password: 'password') }

    before do
      allow(Collection).to receive(:find).with(parent.id).and_return(parent)
      allow(Role).to receive(:find_by).and_call_original

      [parent, project].each do |collection|
        collection.create_collection_groups
        Collection::DEFAULT_GROUP_ROLES.each do |role|
          group = collection.send("#{role}_group")
          allow(Role).to receive(:find_by).with(name: collection.id.concat("_#{role}")).and_return(group)
        end
      end

      parent.managers << parent_manager
      parent.depositors << parent_depositor
      parent.viewers << parent_viewer
      parent.user_groups.each(&:save)

      project.copy_parent_membership(parent.id)
    end

    it 'copies the parent members to the child collection' do
      expect(project.managers).to include(parent_manager)
      expect(project.depositors).to include(parent_depositor)
      expect(project.viewers).to include(parent_viewer)
    end
  end

  describe 'user groups' do
    let(:collection) { Collection.create(title: ['collection title'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id) }
    let(:user1) { User.new(email: 'email1@email.com', password: 'password') }
    let(:user2) { User.new(email: 'email2@email.com', password: 'password') }
    let(:user3) { User.new(email: 'email3@email.com', password: 'password') }
    let(:user4) { User.new(email: 'email4@email.com', password: 'password') }
    let(:user5) { User.new(email: 'email5@email.com', password: 'password') }
    let(:user6) { User.new(email: 'email6@email.com', password: 'password') }
    let(:all_users) { [user, user1, user2, user3, user4, user5, user6] }

    before do
      collection.create_collection_groups
      collection.managers_group.users << user1 << user2
      collection.depositors_group.users << user3 << user4
      collection.viewers_group.users << user5 << user6
      collection.user_groups.each(&:save)
    end

    describe '#managers, #depositors, #viewers' do
      it 'returns users for each of the different roles' do
        expect(collection.managers).to match_array([user, user1, user2])
        expect(collection.depositors).to match_array([user3, user4])
        expect(collection.viewers).to match_array([user5, user6])
      end
    end

    describe '#group_members' do
      it 'returns all users with a collection role' do
        expect(collection.group_members).to match_array(all_users)
      end
    end
  end

  describe '#destroy_default_groups' do
    context 'the deleted collection is not a team or project' do
      let(:another) { Collection.create(title: ['Another'], collection_type_gid: another_collection_type.gid, depositor: user.ms_id) }

      it 'does not call #destroy_default_groups' do
        expect(another).not_to receive(:destroy_default_groups)
        another.destroy
      end
    end

    context 'the deleted collection is a team or project' do
      let!(:team) { Collection.create(title: ['Team_A'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id) }

      it 'calls #destroy_default_groups' do
        expect(team).to receive(:destroy_default_groups)
        team.destroy
      end

      it 'destroys all of the default user groups when a team or project is destroyed' do
        team.create_collection_groups
        expect { team.destroy }.to change { Role.count }.by(-3)
      end
    end
  end
end
