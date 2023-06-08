require 'rails_helper'

RSpec.describe Morphosource::Collections::NestedCollectionQueryService do

  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:repository)        { Blacklight::Solr::Repository.new(blacklight_config) }
  let(:user)              { User.create(email:'user@email.com', password: 'password') }
  let(:ability)           { ::Ability.new(user) }
  let(:current_ability)   { ability }
  let(:scope)             { double('Scope', can?: true, current_ability: current_ability, repository: repository, blacklight_config: blacklight_config) }

  describe '.available_child_collections' do
    subject { described_class.available_project_collections(parent: parent_double, scope: scope) }

    describe 'parent is not nestable' do
      let(:parent_double) { double(nestable?: false, team?: true) }

      it 'returns an empty array' do
        expect(subject).to eq([])
      end
    end

    describe 'user cannot edit the parent' do
      let(:parent_double) { double(nestable?: true, team?: true) }

      let(:scope) { double('Scope', can?: false, current_ability: current_ability, repository: repository, blacklight_config: blacklight_config) }

      it 'returns an empty array' do
        expect(subject).to eq([])
      end
    end

    describe 'parent is not a team' do
      let(:parent_double) { double(nestable?: true, team?: false) }

      it 'returns an empty array' do
        expect(subject).to eq([])
      end
    end

    describe 'parent is nestable, user can edit the parent, and the parent is a team' do
      let(:depositor)               { User.create(email:'depositor@email.com', password: 'password') }
      let(:team)                    { Collection.create(title: ['Team'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id) }
      let(:another_team)            { Collection.create(title: ['Another Team'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id) }
      let(:projectA)                { Collection.create(title: ['ProjectA'], collection_type_gid: project_collection_type.gid, depositor: depositor.ms_id) }
      let(:projectB)                { Collection.create(title: ['ProjectB'], collection_type_gid: project_collection_type.gid, depositor: depositor.ms_id) }
      let(:projectC)                { Collection.create(title: ['ProjectC'], collection_type_gid: project_collection_type.gid, depositor: depositor.ms_id) }
      let(:projectD)                { Collection.create(title: ['ProjectD'], collection_type_gid: project_collection_type.gid, depositor: depositor.ms_id) }
      let(:collections)             { [projectA, projectB, projectC, projectD, team, another_team] }

      before do
        collections.each do |collection|
          collection.create_collection_groups
          Morphosource::Collections::PermissionsCreateService.create_default(collection: collection)
        end
        # user has individual edit access to projectB
        projectB.edit_users += [user]
        # user manages projectC
        projectC.managers << user
        projectC.managers_group.save
        # user manages projectD
        projectD.managers << user
        projectD.managers_group.save
        # nest projectD in team
        projectD.member_of_collections << team
        collections.each(&:save!)
        user.reload
      end

      subject { described_class.available_project_collections(parent: team, scope: scope) }

      it 'returns projects without parents that the user can edit' do
        expect(scope).to receive(:can?).with(:edit, team).and_return(true)
        expect(described_class).to receive(:query_solr).with(collection: team, access: :edit, scope: scope, limit_to_id: nil, nest_direction: :as_child).and_call_original

        expect(subject.map(&:id)).to match_array([projectB.id, projectC.id])
      end
    end
  end
end
