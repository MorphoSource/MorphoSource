require 'rails_helper'

RSpec.describe Hyrax::Dashboard::NestedCollectionsSearchBuilder do
  let(:another_collection_type) { Hyrax::CollectionType.create(title: "Another", machine_id: 99)}

  let(:project_a) { Collection.new(id: 'Project_A', collection_type_gid: project_collection_type.to_global_id )}
  let(:team_a) { Collection.new(id: 'Team_A', collection_type_gid: team_collection_type.to_global_id )}
  let(:another) { Collection.new(id: 'Another', collection_type_gid: another_collection_type.to_global_id )}

  let(:scope) { double(current_ability: ability, blacklight_config: CatalogController.blacklight_config) }
  let(:access) { :deposit }
  let(:user) { User.create(email: "email@email.com", password: "password", ms_id: "abc123") }
  let(:ability) { ::Ability.new(user) }

  let(:builder) { described_class.new(scope: scope, access: access, collection: collection, nest_direction: nest_direction) }

  let(:solr_params) { {} }

  before do
    allow(Hyrax::CollectionType).to receive(:find_by).with(title: "Team").and_return(team_collection_type)
    allow(Hyrax::CollectionType).to receive(:find_by).with(title: "Project").and_return(project_collection_type)
  end

  describe '#show_only_other_collections_of_the_same_collection_type' do
    let(:collection) { project_a }
    let(:nest_direction) { :as_child }
    subject { builder }

    it 'should call #show_only_valid_collection_types' do
      expect(subject).to receive(:show_only_valid_collection_types).with(solr_params)
      subject.show_only_other_collections_of_the_same_collection_type(solr_params)
    end
  end

  describe '#show_only_valid_collection_types' do
    subject { builder.show_only_valid_collection_types(solr_params) }

    describe 'adding project as subcollection' do
      let(:collection) { project_a }
      let(:nest_direction) { :as_parent }

      it 'should build a query for teams' do
        subject
        expect(solr_params.fetch(:fq)).to match_array([
          "_query_:\"{!field f=collection_type_gid_ssim}#{team_collection_type.to_global_id}\"", 
          "-{!graph from=id to=member_of_collection_ids_ssim maxDepth=1}id:#{collection.id}", 
          "-{!graph to=id from=member_of_collection_ids_ssim}id:#{collection.id}"
        ])
      end
    end

    describe 'adding a team as a parent collection' do
      let(:collection) { team_a }
      let(:nest_direction) { :as_child }
      it 'should build a query for projects' do
        subject
        expect(solr_params.fetch(:fq)).to match_array([
          "_query_:\"{!field f=collection_type_gid_ssim}#{project_collection_type.to_global_id}\"", 
          "-{!graph from=id to=member_of_collection_ids_ssim}id:#{collection.id}", 
          "-{!graph to=id from=member_of_collection_ids_ssim maxDepth=1}id:#{collection.id}"
        ])
      end
    end

    describe 'adding another collection type as subcollection' do
      let(:collection) { another }
      let(:nest_direction) { :as_parent }
      it 'should build a query for that collection type only' do
        subject
        expect(solr_params.fetch(:fq)).to match_array([
          "_query_:\"{!field f=collection_type_gid_ssim}#{collection.collection_type_gid}\"", 
          "-{!graph from=id to=member_of_collection_ids_ssim maxDepth=1}id:#{collection.id}", 
          "-{!graph to=id from=member_of_collection_ids_ssim}id:#{collection.id}"
        ])
      end
    end

    describe 'adding another collection type as a parent collection' do
      let(:collection) { another }
      let(:nest_direction) { :as_child }
      it 'should bulid a query for that collection type only' do
        subject
        expect(solr_params.fetch(:fq)).to match_array([
          "_query_:\"{!field f=collection_type_gid_ssim}#{collection.collection_type_gid}\"", 
          "-{!graph from=id to=member_of_collection_ids_ssim}id:#{collection.id}", 
          "-{!graph to=id from=member_of_collection_ids_ssim maxDepth=1}id:#{collection.id}"
        ])
      end
    end
  end
end
