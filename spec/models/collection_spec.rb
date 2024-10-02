# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collection, type: :model do
  let(:another_collection_type) { Hyrax::CollectionType.create(title: 'Another', machine_id: 99) }
  let(:user)                    { User.create(email: 'email@email.com', password: 'password', ms_id: 'abc123') }
  let(:team)                    { Collection.create(title: ['Team_B'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id) }
  let(:project)                 { Collection.create(title: ['Project_B'], collection_type_gid: project_collection_type.gid, depositor: user.ms_id) }
  let(:media)                   { Media.create(title: ['media']) }
  let(:media2)                  { Media.create(title: ['media2']) }
  let(:media3)                  { Media.create(title: ['media3']) }
  let(:all_media)               { [media, media2, media3] }


  describe 'organization methods' do
    let!(:org1)  { Organization.create(title: ['title'], team_id: [team.id]) }
    let!(:org2)  { Organization.create(title: ['title'], team_id: []) }
    let!(:org3)  { Organization.create(title: ['title'], team_id: []) }

    before do
      project.member_of_collections << team
      project.save
    end

    describe '#organization' do
      it 'returns the organization linked to the team' do
        expect(team.organization).to eq(org1)
      end
      it 'returns the organization linked to a parent team' do
        expect(project.organization).to eq(org1)
      end
    end

    describe '#organization_name' do
      it 'returns the title of the organization linked to the team' do
        expect(team.organization_name).to eq(org1.title)
      end
      it 'returns the title of the organization linked to a parent team' do
        expect(project.organization_name).to eq(org1.title)
      end
    end
  end

  describe '#human_readable_type' do
    let(:another_collection)  { Collection.create(title: ['Another'], collection_type_gid: another_collection_type.gid, depositor: user.ms_id) }

    it 'returns team and project' do
      expect(team.human_readable_type).to eq "Team"
      expect(project.human_readable_type).to eq "Project"
      expect(another_collection.human_readable_type).to eq "Another"
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

  describe '#copy_parent_membership, #remove_parent_membership' do
    let(:manager)             { FactoryBot.create(:contributor) }
    let(:editor)              { FactoryBot.create(:contributor) }
    let(:depositor)           { FactoryBot.create(:contributor) }
    let(:downloader)          { FactoryBot.create(:registered_user) }
    let(:viewer)              { FactoryBot.create(:registered_user) }

    let(:project_manager)     { FactoryBot.create(:contributor) }
    let(:project_editor)      { FactoryBot.create(:contributor) }
    let(:project_depositor)   { FactoryBot.create(:contributor) }
    let(:project_downloader)  { FactoryBot.create(:registered_user) }
    let(:project_viewer)      { FactoryBot.create(:registered_user) }

    let(:organization)        { FactoryBot.create(:organization_collection, depositor: user.ms_id) }
    let(:collections)         { [team, organization] }

    before do
      organization.managers << user
      organization.managers_group.save
    end

    context 'the parent collection is a team or organization' do
      before do
        allow(Collection).to receive(:find).with(team.id).and_return(team)
        allow(Collection).to receive(:find).with(organization.id).and_return(organization)

        collections.each do |parent|
          parent.create_collection_groups
          parent.managers << manager
          parent.editors << editor
          parent.depositors << depositor
          parent.downloaders << downloader
          parent.viewers << viewer
          parent.user_groups.each(&:save)
        end

        project.create_collection_groups
      end

      it 'copies parent membership and removes parent members except designated user from the project' do
        collections.each do |parent|
          # project initially has no members except for the depositor
          expect(project.managers).to match_array([user])
          expect(project.editors).to match_array([])
          expect(project.depositors).to match_array([])
          expect(project.downloaders).to match_array([])
          expect(project.viewers).to match_array([])

          # copy parent membership to project
          project.copy_parent_membership(parent.id)

          expect(project.managers).to include(manager)
          expect(project.editors).to include(editor)
          expect(project.depositors).to include(depositor)
          expect(project.downloaders).to include(downloader)
          expect(project.viewers).to include(viewer)

          # add additional members to the project
          project.managers << project_manager
          project.editors << project_editor
          project.depositors << project_depositor
          project.downloaders << project_downloader
          project.viewers << project_viewer
          project.user_groups.each(&:save)

          expect(project.managers).to match_array([manager, project_manager, user])
          expect(project.editors).to match_array([editor, project_editor])
          expect(project.depositors).to match_array([depositor, project_depositor])
          expect(project.downloaders).to match_array([downloader, project_downloader])
          expect(project.viewers).to match_array([viewer, project_viewer])

          # remove parent membership from project
          project.remove_parent_membership(parent, manager)

          expect(project.managers).to match_array([manager, project_manager])
          expect(project.editors).to match_array([ project_editor])
          expect(project.depositors).to match_array([project_depositor])
          expect(project.downloaders).to match_array([project_downloader])
          expect(project.viewers).to match_array([ project_viewer])

          # reset project groups
          project.managers.delete(manager)
          project.managers.delete(project_manager)
          project.managers << user
          project.editors.delete(project_editor)
          project.depositors.delete(project_depositor)
          project.downloaders.delete(project_downloader)
          project.viewers.delete(project_viewer)
          project.user_groups.each(&:save)
        end
      end
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
    end

    context 'parameter is array of work ids' do
      it 'adds works to the collection' do
        team.add_member_objects(work_ids)
        expect(team.member_objects).to match_array(works)
      end

      it 'applies permissions to the works' do
        team.add_member_objects(work_ids)
        works.each do |work|
          work.reload
          expect(work.edit_groups).to match_array([team.managers_group.name, team.editors_group.name, 'admin'])
          expect(work.download_groups).to match_array([team.downloaders_group.name])
          expect(work.read_groups).to match_array([team.viewers_group.name])
        end
      end
      it 'calls inherit permissions' do
        works.each do |work|
          expect(InheritPermissionsJob).to receive(:perform_later).with(work.id)
        end
        team.add_member_objects(work_ids)
      end
    end

    context 'parameter is array of works' do
      it 'adds works to the collection' do
        team.add_member_objects(works)
        expect(team.member_objects).to match_array(works)
      end

      it 'applies permissions to the works' do
        team.add_member_objects(works)
        works.each do |work|
          work.reload
          expect(work.edit_groups).to match_array([team.managers_group.name, team.editors_group.name, 'admin'])
          expect(work.download_groups).to match_array([team.downloaders_group.name])
          expect(work.read_groups).to match_array([team.viewers_group.name])
        end
      end
      it 'calls inherit permissions' do
        works.each do |work|
          expect(InheritPermissionsJob).to receive(:perform_later).with(work.id)
        end
        team.add_member_objects(works)
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
    end

    it 'removes the member objects' do
      team.remove_member_objects(work_ids)
      expect(team.member_objects).to match_array([])
    end

    it 'removes the collection permissions from the works' do
      team.remove_member_objects(work_ids)
      works.each do |work|
        work.reload
        expect(work.edit_groups).to match_array(['admin'])
        expect(work.download_groups).to match_array([])
        expect(work.read_groups).to match_array([])
      end
    end
    it 'calls inherit permissions' do
      works.each do |work|
        expect(InheritPermissionsJob).to receive(:perform_later).with(work.id)
      end
      team.add_member_objects(work_ids)
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

  describe '#child_projects' do
    before do
      project.member_of_collections << team
      project.save
    end
    it { expect(team.child_projects).to match_array([project]) }
  end

  describe 'destroy callbacks' do
    let!(:specimen)  { BiologicalSpecimen.create(title: ['specimen'], vouchered: ['Yes']) }
    let!(:cho)       { CulturalHeritageObject.create(title: ['cho'], vouchered: ['Yes']) }
    let!(:cho2)      { CulturalHeritageObject.create(title: ['cho2'], vouchered: ['Yes']) }
    let!(:device)    { Device.create(title: ['device'], modality: ['Photogrammetry']) }
    let!(:ie)        { ImagingEvent.create(title: ['ie'], device_id: [device.id], ie_modality: device.modality, physical_object_id: [specimen.id]) }
    let!(:ie2)       { ImagingEvent.create(title: ['ie'], device_id: [device.id], ie_modality: device.modality, physical_object_id: [cho.id]) }
    let!(:ie3)       { ImagingEvent.create(title: ['ie'], device_id: [device.id], ie_modality: device.modality, physical_object_id: [cho2.id]) }
    let(:objects)    { [specimen, cho, cho2] }
    let(:imaging_events)  { [ie, ie2, ie3] }
    let(:all_members) { all_media + [project] }
    before do
      project.member_of_collections << team
      project.save!

      ie.ordered_members << media
      ie2.ordered_members << media2
      ie3.ordered_members << media3

      imaging_events.each(&:update_index)

      all_media.each do |m|
        m.member_of_collections << team
        m.save!
      end
      objects.each(&:update_index)
    end

    it 'reindexes members and related objects when the collection is destroyed' do
      all_media.each do |work|
        solr_doc = SolrDocument.find(work.id)
        expect(solr_doc['member_of_collection_ids_ssim']).to include(team.id)
        expect(solr_doc['member_of_team_ids_ssim']).to include(team.id)
      end
      expect(SolrDocument.find(project.id)['member_of_collection_ids_ssim']).to include(team.id)
      objects.each do |work|
        solr_doc = SolrDocument.find(work.id)
        expect(solr_doc['media_member_of_team_ids_ssim']).to include(team.id)
      end
      team.destroy
      all_media.each do |work|
        solr_doc = SolrDocument.find(work.id)
        expect(solr_doc['member_of_collection_ids_ssim']).to be(nil)
        expect(solr_doc['member_of_team_ids_ssim']).to be(nil)
      end
      expect(SolrDocument.find(project.id)['member_of_collection_ids_ssim']).to be(nil)
      objects.each do |work|
        solr_doc = SolrDocument.find(work.id)
        expect(solr_doc['media_member_of_collection_ids_ssim']).to be(nil)
      end
    end
  end

  describe 'search_builder_class' do
    it { expect(project.search_builder_class).to eq( Morphosource::Users::MyMediaSearchBuilder) }
  end
end
