require 'rails_helper'

RSpec.describe Hyrax::Collections::NestedCollectionQueryService, clean_repo: true do

  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:repository) { Blacklight::Solr::Repository.new(blacklight_config) }
  let(:user) { User.create(email: 'user@email.com', password: 'password') }
  let(:ability) { ::Ability.new(user) }
  let(:current_ability) { ability }
  let(:scope) { double('Scope', can?: true, current_ability: current_ability, repository: repository, blacklight_config: blacklight_config) }

  let(:another_collection_type) { Hyrax::CollectionType.create(title: "Another", machine_id: 99) }

  describe '.parent_and_child_can_nest?' do
    subject { described_class.parent_and_child_can_nest?(parent: parent, child: child, scope: scope) }

    describe 'parent and child are the same collection' do
      let(:parent)  { Collection.new(id: 'Parent', collection_type_gid: team_collection_type.gid ) }
      let(:child) { parent }

      it { is_expected.to eq(false) }
    end
    describe 'given parent and child are not the same collection' do
      describe 'parent and child are different collection types' do
        describe 'parent is a team' do
          let(:parent)  { Collection.new(id: 'Parent', collection_type_gid: team_collection_type.gid ) }
          describe 'child is not a project' do
            let(:child) { Collection.new(id: 'Child', collection_type_gid: another_collection_type.gid)}

            it { is_expected.to eq(false) }
          end
          describe 'child is a project' do
            let(:child) { Collection.new(id: 'Child', collection_type_gid: project_collection_type.gid)}

            describe 'child has a parent' do
              let(:another_team) { Collection.new(id: 'Another_Team', collection_type_gid: team_collection_type.gid)}

              before do
                child.member_of_collections << another_team
                child.save
              end

              it { is_expected.to eq(false) }
            end

            describe 'child does not have a parent' do
              describe 'the parent is an available parent collection' do
                before do
                  allow(described_class).to receive(:available_parent_collections).with(child: child, scope: scope, limit_to_id: parent.id).and_return(['parent'])
                end

                describe 'the child is an available child collection' do
                  before do
                    allow(described_class).to receive(:available_child_collections).with(parent: parent, scope: scope, limit_to_id: child.id).and_return(['child'])
                  end

                  it { is_expected.to eq(true) }
                end

                describe 'the child is not an available child collection' do
                  before do
                    allow(described_class).to receive(:available_child_collections).with(parent: parent, scope: scope, limit_to_id: child.id).and_return([])
                  end
                  it { is_expected.to eq(false) }
                end
              end
              describe 'the parent is not an available parent collection' do
                before do
                  allow(described_class).to receive(:available_parent_collections).with(child: child, scope: scope, limit_to_id: parent.id).and_return([])
                end
                it { is_expected.to eq(false) }
              end
            end
          end
        end
      end
      describe 'parent and child are the same collection type' do
        describe 'the collections are teams' do
          let(:parent)  { Collection.new(id: 'Parent', collection_type_gid: team_collection_type.gid ) }
          let(:child)   { Collection.new(id: 'Child', collection_type_gid: team_collection_type.gid) }

          it { is_expected.to eq(false) }
        end
        describe 'the collections are projects' do
          let(:parent)  { Collection.new(id: 'Parent', collection_type_gid: project_collection_type.gid ) }
          let(:child)   { Collection.new(id: 'Child', collection_type_gid: project_collection_type.gid) }

          it { is_expected.to eq(false) }
        end
        describe 'the collections are another collection type' do
          let(:parent)  { Collection.new(id: 'Parent', collection_type_gid: another_collection_type.gid ) }
          let(:child)   { Collection.new(id: 'Child', collection_type_gid: another_collection_type.gid) }
          describe 'the parent is an available parent collection' do
            before do
              allow(described_class).to receive(:available_parent_collections).with(child: child, scope: scope, limit_to_id: parent.id).and_return(['parent'])
            end
            describe 'the child is an available child collection' do
              before do
                allow(described_class).to receive(:available_child_collections).with(parent: parent, scope: scope, limit_to_id: child.id).and_return(['child'])
              end
              it { is_expected.to eq(true) }
            end
            describe 'the child is not an available child collection' do
              before do
                allow(described_class).to receive(:available_child_collections).with(parent: parent, scope: scope, limit_to_id: child.id).and_return([])
              end
              it { is_expected.to eq(false) }
            end
          end
          describe 'the parent is not an available parent collection' do
            before do
              allow(described_class).to receive(:available_parent_collections).with(child: child, scope: scope, limit_to_id: parent.id).and_return([])
            end
            it { is_expected.to eq(false) }
          end
        end
      end
    end
  end

  describe '.available_child_collections' do
    describe 'given parent is not nestable?' do
      subject { described_class.available_child_collections(parent: parent_double, scope: scope) }

      let(:parent_double) { double(nestable?: false) }

      it { is_expected.to eq([]) }
    end

    describe 'given parent is nestable?' do
      describe 'and cannot deposit the parent' do
        subject { described_class.available_child_collections(parent: parent_double, scope: scope) }

        let(:parent_double) { double(nestable?: true) }

        it 'returns an empty array' do
          expect(scope).to receive(:can?).with(:deposit, parent_double).and_return(false)
          expect(described_class).not_to receive(:query_solr)
          expect(subject).to eq([])
        end
      end
      describe 'and given can deposit the parent' do
        describe 'the parent is a project' do
          subject { described_class.available_child_collections(parent: parent_project, scope: scope) }

          let(:parent_project) { Collection.new(id: 'Parent_Project', collection_type_gid: project_collection_type.gid ) }

          it 'returns an empty array' do
            expect(scope).to receive(:can?).with(:deposit, parent_project).and_return(true)
            expect(described_class).not_to receive(:query_solr)
            expect(subject).to eq([])
          end
        end
        describe 'the parent is not a project', with_nested_reindexing: true do
          # using create option here because permission template is required for testing :deposit access
          let!(:project_1) do
            create(:public_collection,
            id: 'Project_1',
            collection_type_gid: project_collection_type.gid,
            user: user,
            with_permission_template: true,
            member_of_collections: [team_a],
            with_nesting_attributes:
            { ancestors: ['Team_A'],
              parent_ids: ['Team_A'],
              pathnames: ['Team_A/Project_1'],
              depth: 2 })
          end

          let!(:project_2) do
            create(:public_collection,
            id: 'Project_2',
            collection_type_gid: project_collection_type.gid,
            user: user,
            with_permission_template: true,
            member_of_collections: [],
            with_nesting_attributes:
            { ancestors: [],
              parent_ids: [],
              pathnames: ['Project_2'],
              depth: 1 })
          end

          let!(:team_a) do
            create(:public_collection,
            id: 'Team_A',
            collection_type_gid: team_collection_type.gid,
            user: user,
            with_permission_template: true,
            with_nesting_attributes:
            { ancestors: [],
              parent_ids: [],
              pathnames: ['Team_A'],
              depth: 1 })
          end

          let!(:team_b) do
            create(:public_collection,
            id: 'Team_B',
            collection_type_gid: team_collection_type.gid,
            user: user,
            with_permission_template: true,
            with_nesting_attributes:
            { ancestors: [],
              parent_ids: [],
              pathnames: ['Team_B'],
              depth: 1 })
          end

          let!(:another_a) do
            create(:public_collection,
            id: 'Another_A',
            collection_type_gid: another_collection_type.gid,
            user: user,
            with_permission_template: true,
            with_nesting_attributes:
            { ancestors: [],
              parent_ids: [],
              pathnames: ['Another_A'],
              depth: 1 })
          end

          let!(:another_b) do
            create(:public_collection,
            id: 'Another_B',
            collection_type_gid: another_collection_type.gid,
            user: user,
            with_permission_template: true,
            with_nesting_attributes:
            { ancestors: [],
              parent_ids: [],
              pathnames: ['Another_B'],
              depth: 1 })
          end

          describe 'the parent is a team' do
            subject { described_class.available_child_collections(parent: team_a, scope: scope) }

            it 'returns an array of projects minus any projects that already have parents' do
              expect(scope).to receive(:can?).with(:deposit, team_a).and_return(true)
              expect(described_class).to receive(:query_solr).with(collection: team_a, access: :read, scope: scope, limit_to_id: nil, nest_direction: :as_child).and_call_original
              expect(subject.map(&:id)).to contain_exactly(project_2.id)
            end
          end

          describe 'the parent is not a team or project' do
            subject { described_class.available_child_collections(parent: another_a, scope: scope) }

            it 'returns an array of the same collection type minus the child collection' do
              expect(scope).to receive(:can?).with(:deposit, another_a).and_return(true)
              expect(described_class).to receive(:query_solr).with(collection: another_a, access: :read, scope: scope, limit_to_id: nil, nest_direction: :as_child).and_call_original
              expect(subject.map(&:id)).to contain_exactly(another_b.id)
            end
          end
        end
      end
    end
  end

  describe '.available_parent_collections' do
    describe 'given child is not nestable?' do
      subject { described_class.available_parent_collections(child: child_double, scope: scope) }

      let(:child_double) { double(nestable?: false) }

      it { is_expected.to eq([]) }
    end

    describe 'given child is nestable?' do
      describe 'and cannot read the child' do
        subject { described_class.available_parent_collections(child: child_double, scope: scope) }

        let(:child_double) { double(nestable?: true) }

        it 'returns an empty array' do
          expect(scope).to receive(:can?).with(:read, child_double).and_return(false)
          expect(described_class).not_to receive(:query_solr)
          expect(subject).to eq([])
        end
      end

      describe 'and can read the child' do
        describe 'and the child is a team' do
          subject { described_class.available_parent_collections(child: child_team, scope: scope) }

          let(:child_team) { Collection.new(id: 'Child_Team', collection_type_gid: team_collection_type.gid )}

          it 'returns an empty array' do
            expect(child_team).to receive(:try).with(:nestable?).and_return(true)
            expect(scope).to receive(:can?).with(:read, child_team).and_return(true)
            expect(described_class).not_to receive(:query_solr)
            expect(subject).to eq([])
          end
        end
        describe 'and the child is a project with a parent' do
          subject { described_class.available_parent_collections(child: child_project, scope: scope) }

          let(:child_project) { Collection.new(id: 'Child_Team', collection_type_gid: project_collection_type.gid )}

          it 'returns an empty array' do
            expect(child_project).to receive(:try).with(:nestable?).and_return(true)
            expect(scope).to receive(:can?).with(:read, child_project).and_return(true)
            expect(child_project).to receive(:parent?).and_return(true)
            expect(described_class).not_to receive(:query_solr)
            expect(subject).to eq([])
          end
        end

        describe 'and the child is not a team or a project with a parent', with_nested_reindexing: true do

          # TODO: update to use _lw collections.
          let!(:project_1) do
            create(:public_collection,
            id: 'Project_1',
            collection_type_gid: project_collection_type.gid,
            user: user,
            with_permission_template: true,
            member_of_collections: [],
            with_nesting_attributes:
            { ancestors: [],
              parent_ids: [],
              pathnames: ['Project_1'],
              depth: 1 })
          end

          let!(:project_2) do
            create(:public_collection,
            id: 'Project_2',
            collection_type_gid: project_collection_type.gid,
            user: user,
            with_permission_template: true,
            member_of_collections: [],
            with_nesting_attributes:
            { ancestors: [],
              parent_ids: [],
              pathnames: ['Project_2'],
              depth: 1 })
          end

          let!(:team_a) do
            create(:public_collection,
            id: 'Team_A',
            collection_type_gid: team_collection_type.gid,
            user: user,
            with_permission_template: true,
            with_nesting_attributes:
            { ancestors: [],
              parent_ids: [],
              pathnames: ['Team_A'],
              depth: 1 })
          end

          let!(:team_b) do
            create(:public_collection,
            id: 'Team_B',
            collection_type_gid: team_collection_type.gid,
            user: user,
            with_permission_template: true,
            with_nesting_attributes:
            { ancestors: [],
              parent_ids: [],
              pathnames: ['Team_B'],
              depth: 1 })
          end

          let!(:another_a) do
            create(:public_collection,
            id: 'Another_A',
            collection_type_gid: another_collection_type.gid,
            user: user,
            with_permission_template: true,
            with_nesting_attributes:
            { ancestors: [],
              parent_ids: [],
              pathnames: ['Another_A'],
              depth: 1 })
          end

          let!(:another_b) do
            create(:public_collection,
            id: 'Another_B',
            collection_type_gid: another_collection_type.gid,
            user: user,
            with_permission_template: true,
            with_nesting_attributes:
            { ancestors: [],
              parent_ids: [],
              pathnames: ['Another_B'],
              depth: 1 })
          end

          describe 'the child is a project' do
            subject { described_class.available_parent_collections(child: project_1, scope: scope) }

            it 'returns an array of team collections only' do
              expect(scope).to receive(:can?).with(:read, project_1).and_return(true)
              expect(described_class).to receive(:query_solr).with(collection: project_1, access: :deposit, scope: scope, limit_to_id: nil, nest_direction: :as_parent).and_call_original
              expect(subject.map(&:id)).to contain_exactly(team_a.id, team_b.id)
            end
          end

          describe 'the child is another collection type' do
            subject { described_class.available_parent_collections(child: another_a, scope: scope) }

            it 'returns an array of the same collection type minus the child collection' do
              expect(scope).to receive(:can?).with(:read, another_a).and_return(true)
              expect(described_class).to receive(:query_solr).with(collection: another_a, access: :deposit, scope: scope, limit_to_id: nil, nest_direction: :as_parent).and_call_original
              expect(subject.map(&:id)).to contain_exactly(another_b.id)
            end
          end
        end
      end
    end
  end
end
