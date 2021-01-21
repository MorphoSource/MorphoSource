# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collection, type: :model do
  let(:team_collection_type)    { Hyrax::CollectionType.create(title: 'Team', machine_id: 88) }
  let(:project_collection_type) { Hyrax::CollectionType.create(title: 'Project', machine_id: 77) }
  let(:another_collection_type) { Hyrax::CollectionType.create(title: 'Another', machine_id: 99) }
  let(:user)                    { User.create(email: 'email@email.com', password: 'password', ms_id: 'abc123') }
  let(:team)                    { Collection.create(title: ['Team_B'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id) }
  let(:project)                 { Collection.create(title: ['Project_B'], collection_type_gid: project_collection_type.gid, depositor: user.ms_id) }
  let(:media)     { Media.create(title: ['media']) }
  let(:media2)    { Media.create(title: ['media2']) }
  let(:media3)    { Media.create(title: ['media3']) }


  describe '#organization' do
    let!(:org1)  { Organization.create(title: ['title'], team_id: [team.id]) }
    let!(:org2)  { Organization.create(title: ['title'], team_id: []) }
    let!(:org3)  { Organization.create(title: ['title'], team_id: []) }

    it 'returns the organization linked to the team' do
      expect(team.organization).to eq(org1)
    end
  end

  # override Hyrax::CollectionBehavior to add editors and downloaders to read_groups
  describe '#permission_template_read_groups' do
    before do
      team.create_collection_groups
      Morphosource::Collections::PermissionsCreateService.create_default(collection: team)
    end

    it 'returns collection editors, depositors, downloaders, and viewers' do
      expect(team.permission_template_read_groups).to match_array([team.editors_group, team.depositors_group, team.downloaders_group, team.viewers_group].map(&:name))
    end
  end

  describe '#human_readable_type' do
    let(:another_collection)  { Collection.create(title: ['Another'], collection_type_gid: another_collection_type.gid, depositor: user.ms_id) }

    it 'returns team and project' do
      expect(team.human_readable_type).to eq "Team"
      expect(project.human_readable_type).to eq "Project"
      expect(another_collection.human_readable_type).to eq "Collection"
    end
  end

  describe '#create_collection_groups' do

    it 'creates manager, depositor, editor, downloader, and viewer groups' do
      expect { team.create_collection_groups }.to change { Role.count }.by(5)
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
    let(:parent)            { Collection.create(title: ['Parent'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id) }
    let(:parent_manager)    { User.create(email: 'manager@email.com', password: 'password') }
    let(:parent_editor)     { User.create(email: 'editor@email.com', password: 'password') }
    let(:parent_depositor)  { User.create(email: 'depositor@email.com', password: 'password') }
    let(:parent_downloader) { User.create(email: 'downloader@email.com', password: 'password') }
    let(:parent_viewer)     { User.create(email: 'viewer@email.com', password: 'password') }

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
      parent.editors << parent_editor
      parent.depositors << parent_depositor
      parent.downloaders << parent_downloader
      parent.viewers << parent_viewer
      parent.user_groups.each(&:save)
      project.copy_parent_membership(parent.id)
    end

    it 'copies the parent members to the child collection' do
      expect(project.managers).to include(parent_manager)
      expect(project.editors).to include(parent_editor)
      expect(project.depositors).to include(parent_depositor)
      expect(project.downloaders).to include(parent_downloader)
      expect(project.viewers).to include(parent_viewer)
    end
  end

  describe 'user groups' do
    let(:collection)  { Collection.create(title: ['collection title'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id) }
    let(:user1)       { User.new(email: 'email1@email.com', password: 'password') }
    let(:user2)       { User.new(email: 'email2@email.com', password: 'password') }
    let(:user3)       { User.new(email: 'email3@email.com', password: 'password') }
    let(:user4)       { User.new(email: 'email4@email.com', password: 'password') }
    let(:user5)       { User.new(email: 'email5@email.com', password: 'password') }
    let(:user6)       { User.new(email: 'email6@email.com', password: 'password') }
    let(:user7)       { User.new(email: 'email7@email.com', password: 'password') }
    let(:all_users)   { [user, user1, user2, user3, user4, user5, user6, user7] }

    before do
      collection.create_collection_groups
      collection.managers_group.users << user1 << user2
      collection.editors_group.users << user3
      collection.depositors_group.users << user4
      collection.downloaders_group.users << user7
      collection.viewers_group.users << user5 << user6
      collection.user_groups.each(&:save)
    end

    describe '#managers, #editors, #depositors, #downloaders, #viewers' do
      it 'returns users for each of the different roles' do
        expect(collection.managers).to match_array([user, user1, user2])
        expect(collection.editors).to match_array([user3])
        expect(collection.depositors).to match_array([user4])
        expect(collection.downloaders).to match_array([user7])
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
        expect { team.destroy }.to change { Role.count }.by(-5)
      end
    end
  end

  describe '#add_member_objects' do
    let(:works)     { [media, media2, media3] }
    let(:work_ids)  { [media.id, media2.id, media3.id] }

    before do
      team.create_collection_groups
      Morphosource::Collections::PermissionsCreateService.create_default(collection: team)
      team.add_member_objects(work_ids)
    end

    it 'adds works to the collection' do
      expect(team.member_objects).to match_array(works)
    end

    it 'applies permissions to the works' do
      works.each do |work|
        work.reload
        expect(work.edit_groups).to match_array([team.managers_group.name, team.editors_group.name, 'admin'])
        expect(work.download_groups).to match_array([team.downloaders_group.name])
        expect(work.read_groups).to match_array([team.viewers_group.name])
      end
    end
  end
  describe '#remove_member_objects' do
    let(:works)     { [media, media2, media3] }
    let(:work_ids)  { [media.id, media2.id, media3.id] }

    before do
      team.create_collection_groups
      Morphosource::Collections::PermissionsCreateService.create_default(collection: team)
      works.each do |work|
        Hyrax::PermissionTemplateApplicator.apply(team.permission_template).to(model: work)
        work.save
      end
      team.remove_member_objects(work_ids)
    end

    it 'removes the member objects' do
      expect(team.member_objects).to match_array([])
    end

    it 'removes the collection permissions from the works' do
      works.each do |work|
        work.reload
        expect(work.edit_groups).to match_array(['admin'])
        expect(work.download_groups).to match_array([])
        expect(work.read_groups).to match_array([])
      end
    end
  end
  describe '#remove_team_access_grants' do
    let(:works)         { [media, media2, media3] }
    let(:work_ids)      { [media.id, media2.id, media3.id] }
    let(:another_group) { double('Role', name: 'another_group') }
    before do
      team.create_collection_groups
      Morphosource::Collections::PermissionsCreateService.create_default(collection: team)
      works.each do |work|
        Hyrax::PermissionTemplateApplicator.apply(team.permission_template).to(model: work)
        work.edit_groups += [another_group.name]
        work.read_groups += [another_group.name]
        work.download_groups += [another_group.name]
        work.save
      end
      team.remove_member_objects(work_ids)
    end
    it 'removes only the collection groups' do
      works.each do |work|
        work.reload
        expect(work.edit_groups).to match_array([another_group.name, 'admin'])
        expect(work.read_groups).to match_array([another_group.name])
        expect(work.download_groups).to match_array([another_group.name])
      end
    end
  end

  describe '#add_date_uploaded' do
    let(:team) { Collection.new(title: ['Test Team'], collection_type_gid: team_collection_type.gid) }

    context 'there is no date uploaded' do
      before do
        team.save
      end

      it 'adds a date uploaded' do
        expect(team.date_uploaded.to_date).to eq(Time.now.to_date)
      end
    end

    context 'there is a date uploaded' do
      let(:existing_date) { "2020-11-11 18:24:45 +0000" }
      
      before do
        team.date_uploaded = existing_date
        team.save
      end

      it 'keeps the original date uploaded' do
        expect(team.date_uploaded).to eq(existing_date)
      end
    end
  end
end
