require 'rails_helper'

RSpec.describe Hyrax::Collections::NestedCollectionQueryService do
  let(:scope) { double('Scope') }
  let(:team_collection_type) { Hyrax::CollectionType.create(title: "Team", machine_id: 88) }
  let(:project_collection_type) { Hyrax::CollectionType.create(title: "Project", machine_id: 77) }
  let(:another_collection_type) { Hyrax::CollectionType.create(title: "Another", machine_id: 99) }
  # teams
  let(:coll_a) { Collection.new(id: 'Collection_A', collection_type_gid: team_collection_type.gid )}
  let(:coll_b) { Collection.new(id: 'Collection_B', collection_type_gid: team_collection_type.gid )}
  # projects
  let(:coll_c) { Collection.new(id: 'Collection_C', collection_type_gid: project_collection_type.gid )}
  let(:coll_d) { Collection.new(id: 'Collection_D', collection_type_gid: project_collection_type.gid )}
  # other
  let(:coll_e) { Collection.new(id: 'Collection_E', collection_type_gid: another_collection_type.gid )}
  let(:coll_f) { Collection.new(id: 'Collection_F', collection_type_gid: another_collection_type.gid )}

  describe '.parent_and_child_can_nest?' do
    subject { described_class.parent_and_child_can_nest?(parent: parent, child: child, scope: scope) }
    describe 'given parent and child are nestable' do
      describe 'all the other conditions pass' do
        before do
          allow(described_class).to receive_message_chain(:available_parent_collections, :none?).and_return(false)
          allow(described_class).to receive_message_chain(:available_child_collections, :none?).and_return(false)
        end
        describe 'parent and child have different collection types' do
          describe 'parent is a Team and child is a Project' do
            let(:parent)  { coll_a }
            let(:child)   { coll_c }
            it 'returns true' do
              expect(subject).to be(true)
            end
          end
          describe 'parent is a Project and child is a Team' do
            let(:parent)  { coll_c }
            let(:child)   { coll_a }
            it 'returns false' do
              expect(subject).to be(false)
            end
          end
          describe 'parent is a Team and child is Another' do
            let(:parent)  { coll_a }
            let(:child)   { coll_e }
            it 'returns false' do
              expect(subject).to be(false)
            end
          end
          describe 'parent is Another and child is a Project' do
            let(:parent)  { coll_e }
            let(:child)   { coll_c }
            it 'returns true' do
              expect(subject).to be(false)
            end
          end
        end
        describe 'parent and child have the same collection types' do
          describe 'parent and child are projects' do
            let(:parent)  { coll_c }
            let(:child)   { coll_d }
            it 'returns true' do
              expect(subject).to be(true)
            end
          end
          describe 'parent and child are teams' do
            let(:parent)  { coll_a }
            let(:child)   { coll_b }
            it 'returns true' do
              expect(subject).to be(true)
            end
          end
          describe 'parent and child are another type' do
            let(:parent)  { coll_e }
            let(:child)   { coll_f }
            it 'returns true' do
              expect(subject).to be(true)
            end
          end
        end
      end
    end
  end
end
