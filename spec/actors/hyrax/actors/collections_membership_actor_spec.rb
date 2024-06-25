require 'rails_helper'

RSpec.describe Hyrax::Actors::CollectionsMembershipActor do

  subject { described_class.new(next_actor) }

  let(:next_actor)            { double(create: true, update: true) }
  let(:work)                  { Media.create(id: "OriginalWork", title: ["Work Being Updated"], depositor: user.ms_id ) }
  let!(:contributor_group)    { Role.create(name: 'contributor') }
  let(:user)                  { User.create(email: 'user@email.com', password: 'password') }
  let(:ability)               { Ability.new(user) }
  let(:teamA)                 { Collection.create(title: ['TeamA'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id) }
  let(:teamB)                 { Collection.create(title: ['TeamB'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id) }
  let(:env)                   { Hyrax::Actors::Environment.new(work, ability, attributes) }

  before do
    user.make_contributor
    user.reload
    teamA.create_collection_groups
    Morphosource::Collections::PermissionsCreateService.create_default(collection: teamA)
  end

  describe '#update' do
    context 'adding a work to a collection' do
      let(:attributes)  { {"member_of_collections_attributes" => { "0" => { "id" => teamA.id, "_destroy" => "false" } } } }

      it 'adds the appropriate permissions' do
        subject.update(env)
        expect(work.read_groups).to match_array([teamA.viewers_group.name])
        expect(work.download_groups).to match_array([teamA.downloaders_group.name])
        expect(work.edit_groups).to match_array(['admin', teamA.managers_group.name, teamA.editors_group.name])
      end
    end

    context 'removing a work from a collection' do
      let(:attributes)  { {"member_of_collections_attributes" => { "0" => { "id" => teamA.id, "_destroy" => "true" } } } }

      before do
        work.member_of_collections << teamA
        Hyrax::PermissionTemplateApplicator.apply(teamA.permission_template).to(model: work)
        work.save!
      end

      it 'removes the appropriate permissions' do
        subject.update(env)
        expect(work.read_groups).to match_array([])
        expect(work.download_groups).to match_array([])
        expect(work.edit_groups).to match_array(['admin'])
      end
    end

    context 'adding and removing a work from a collection' do
      let(:attributes)  { {"member_of_collections_attributes" => { "0" => { "id" => teamA.id, "_destroy" => "true" }, "1" => { "id" => teamB.id, "_destroy" => "false" } } } }

      before do
        teamB.create_collection_groups
        Morphosource::Collections::PermissionsCreateService.create_default(collection: teamB)
        work.member_of_collections << teamA
        Hyrax::PermissionTemplateApplicator.apply(teamA.permission_template).to(model: work)
        work.save!
      end

      it 'adds and removes the appropriate permissions' do
        subject.update(env)
        expect(work.read_groups).to match_array([teamB.viewers_group.name])
        expect(work.download_groups).to match_array([teamB.downloaders_group.name])
        expect(work.edit_groups).to match_array(['admin', teamB.managers_group.name, teamB.editors_group.name])
      end
    end
  end
end
