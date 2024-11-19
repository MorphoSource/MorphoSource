require 'rails_helper'

RSpec.describe Morphosource::UserWorksSearchService do

  let(:user)      { User.create(email: 'registered@email.com', password: 'password') }
  let(:depositor) { User.create(email: 'depositor@email.com', password: 'password') }

  let(:ability)   { ::Ability.new(user) }
  let(:scope)     { double(blacklight_config: CatalogController.blacklight_config, current_ability: ability) }

  let(:projectA)                { Collection.create(title: ['Project_A'], collection_type_gid: project_collection_type.to_global_id, depositor: depositor.ms_id) }
  let(:projectB)                { Collection.create(title: ['Project_B'], collection_type_gid: project_collection_type.to_global_id, depositor: depositor.ms_id) }
  let(:team)                    { Collection.create(title: ['Linked Team'], collection_type_gid: team_collection_type.to_global_id, depositor: depositor.ms_id) }

  before do
    projectA.create_collection_groups
    Morphosource::Collections::PermissionsCreateService.create_default(collection: projectA)
    projectB.create_collection_groups
    Morphosource::Collections::PermissionsCreateService.create_default(collection: projectB)
    team.create_collection_groups
    Morphosource::Collections::PermissionsCreateService.create_default(collection: team)
  end

  describe '.call' do
    it 'instantiates the search service and calls it' do
      expect_any_instance_of(described_class).to receive(:call)
      described_class.call('object','edit',scope)
    end
  end

  describe '#call' do
    subject { described_class.new(work_type, access, scope) }

    describe 'media' do
      let(:work_type) { 'media' }

      # publicly viewable media
      # user has read access, but this media shouldn't be returned in a user's media coun
      let!(:open)                   { Media.create(id: 'open', title: ['open'], visibility: 'open') }
      # private media, user does not have any access
      let!(:restricted)             { Media.create(id: 'restricted', title: ['restricted'], visibility: 'restricted') }

      # user-deposited media
      # user should have edit access to these
      let!(:restricted_deposited)   { Media.create(id: 'restrictedDeposited', title: ['restricted deposited'], visibility: 'restricted', depositor: user.ms_id) }
      let!(:open_deposited)         { Media.create(id: 'openDeposited', title: ['open deposited'], visibility: 'open', depositor: user.ms_id)}

      # user has access to these media after being added to a projectA user group
      let!(:projectA_open)          { Media.create(id: 'projectAopen', title: ['shared open view'], visibility: 'open') }
      let!(:projectA_restricted)    { Media.create(id: 'projectArestricted', title: ['shared restricted view'], visibility: 'restricted') }

      # user has access to these media after being added to a projectB user group
      let!(:projectB_open)          { Media.create(id: 'projectBopen', title: ['shared open download'], visibility: 'open') }
      let!(:projectB_restricted)    { Media.create(id: 'projectBrestricted', title: ['shared restricted download'], visibility: 'restricted') }

      # user has access to these media through an org-linked team
      let!(:org_open)          { Media.create(id: 'orgOpen', title: ['shared open view'], visibility: 'open') }
      let!(:org_restricted)    { Media.create(id: 'orgRestricted', title: ['shared restricted view'], visibility: 'restricted') }

      before do
        # add depositor as edit user for their media
        restricted_deposited.edit_users += [user]
        open_deposited.edit_users += [user]
        [restricted_deposited, open_deposited].each(&:save)
        # add media to their projects
        projectA.add_member_objects([projectA_open.id, projectA_restricted.id])
        projectB.add_member_objects([projectB_open.id, projectB_restricted.id])
        # give view access to all of the organization's linked team members
        org_open.read_groups += team.user_groups
        org_restricted.read_groups += team.user_groups
        [org_open, org_restricted].each(&:save)
      end

      describe 'read access' do
        let(:access)  { 'read' }

        before do
          # give user read access to works in projectA and projectB
          add_user_to_project(projectA, :viewers_group)
          add_user_to_project(projectB, :downloaders_group)
          # add user as an editor to the org linked team
          add_user_to_project(team, :editors_group)
        end

        let(:view_media_ids)  {ids([projectA_open,
                                    projectA_restricted,
                                    projectB_open,
                                    projectB_restricted,
                                    org_open,
                                    org_restricted]) }


        it 'returns media the user has been granted view access to, and does not return publicly viewable media' do
          expect(ids(subject.call.documents)).to match_array(view_media_ids)
        end
      end

      describe 'edit access' do
        let(:access)          { 'edit' }
        let(:edit_media_ids)  { ids([projectB_open,
                                    projectB_restricted,
                                    projectA_open,
                                    projectA_restricted,
                                    open_deposited,
                                    restricted_deposited]) }

        before do
          #give user edit access to works in projectA and projectB
          add_user_to_project(projectA, :managers_group)
          add_user_to_project(projectB, :editors_group)
          subject.instance_variable_set(:@scope, scope)
        end

        it 'returns media the user has been granted edit access to, as well as media the user has deposited' do
          expect(ids(subject.call.documents)).to match_array(edit_media_ids)
        end
      end
    end

    describe 'objects' do
      let(:work_type) { 'object' }

      # open & restricted specimens user does not have access to
      let(:open_specimen)       { BiologicalSpecimen.create(title: ['open specimen'], vouchered: ['Yes'], visibility: 'open') }
      let(:restricted_specimen) { BiologicalSpecimen.create(title: ['restricted specimen'], vouchered: ['Yes'], visibility: 'restricted') }
      # open & restricted cultural heritage objects user does not have access to
      let(:open_cho)            { CulturalHeritageObject.create(title: ['open cho'], vouchered: ['Yes'], visibility: 'open') }
      let(:restricted_cho)      { CulturalHeritageObject.create(title: ['restricted cho'], vouchered: ['Yes'], visibility: 'restricted') }
      # objects that the user has deposited
      let(:deposited_specimen)  { BiologicalSpecimen.create(title: ['deposited_specimen'], vouchered: ['Yes'], visibility: 'open', depositor: user.ms_id) }
      let(:deposited_cho)       { CulturalHeritageObject.create(title: ['deposited_cho'], vouchered: ['Yes'], visibility: 'open', depositor: user.ms_id) }

      before do
        # add depositor as edit user for their objects
        deposited_specimen.edit_users += [user]
        deposited_cho.edit_users += [user]
        [deposited_specimen, deposited_cho].each(&:save)
      end

      describe 'edit access' do
        let(:access)  { 'edit' }

        before do
          subject.instance_variable_set(:@scope, scope)
        end

        let(:edit_object_ids)  {ids([deposited_specimen,
                                    deposited_cho]) }

        it 'returns objects the user has deposited and is able to edit' do
          expect(ids(subject.call.documents)).to match_array(edit_object_ids)
        end
      end
    end
  end

  def ids(objects)
    objects.map(&:id)
  end

  def add_user_to_project(project, group)
    project_group = project.send(group)
    project_group.users << user
    project_group.save
  end
end
