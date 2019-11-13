require 'rails_helper'

RSpec.describe Hyrax::Dashboard::NestedCollectionsSearchBuilder do
  let(:team_collection_type) { Hyrax::CollectionType.create(title: "Team", machine_id: 88) }
  let(:project_collection_type) { Hyrax::CollectionType.create(title: "Project", machine_id: 77) }
  let(:another_collection_type) { Hyrax::CollectionType.create(title: "Another", machine_id: 99)}

  let(:project_a) { Collection.new(id: 'Project_A', collection_type_gid: project_collection_type.gid )}
  let(:team_a) { Collection.new(id: 'Team_A', collection_type_gid: team_collection_type.gid )}
  let(:another) { Collection.new(id: 'Another', collection_type_gid: another_collection_type.gid )}

  let(:scope) { double(current_ability: ability, blacklight_config: CatalogController.blacklight_config) }
  let(:access) { :deposit }
  let(:user) { User.create(email: "email@email.com", password: "password", ms_id: "abc123") }
  let(:ability) { ::Ability.new(user) }
  let(:nesting_attributes) { double(parents: [], pathnames: [collection.id], ancestors: [], depth: 1) }

  let(:builder) { described_class.new(scope: scope, access: access, collection: collection, nesting_attributes: nesting_attributes, nest_direction: nest_direction) }

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
    let(:single_type_as_child) { ["-{!terms f=id}#{collection.id}", "_query_:\"{!field f=collection_type_gid_ssim}#{collection.collection_type_gid}\"", "-_query_:\"{!lucene q.op=OR df=nesting_collection__pathnames_ssim}#{collection.id}\"", "-_query_:\"{!field f=nesting_collection__parent_ids_ssim}#{collection.id}\""] }

    let(:single_type_as_parent) { ["-{!terms f=id}#{collection.id}", "_query_:\"{!field f=collection_type_gid_ssim}#{collection.collection_type_gid}\"", "-_query_:\"{!lucene df=nesting_collection__pathnames_ssim}*#{collection.id}*\""] }

    subject { builder.show_only_valid_collection_types(solr_params) }

    describe 'adding project as subcollection' do
      let(:collection) { project_a }
      let(:nest_direction) { :as_parent }

      it 'should build a query for projects and teams' do
        subject
        expect(solr_params.fetch(:fq)).to match_array(["-{!terms f=id}#{collection.id}", "(_query_:\"{!field f=collection_type_gid_ssim}#{project_collection_type.gid}\" OR _query_:\"{!field f=collection_type_gid_ssim}#{team_collection_type.gid}\")", "-_query_:\"{!lucene df=nesting_collection__pathnames_ssim}*#{collection.id}*\""])
      end
    end

    describe 'adding a team as a parent collection' do
      let(:collection) { team_a }
      let(:nest_direction) { :as_child }
      it 'should build a query for projects and teams' do
        subject
        expect(solr_params.fetch(:fq)).to match_array(["-{!terms f=id}#{collection.id}", "(_query_:\"{!field f=collection_type_gid_ssim}#{project_collection_type.gid}\" OR _query_:\"{!field f=collection_type_gid_ssim}#{team_collection_type.gid}\")", "-_query_:\"{!lucene q.op=OR df=nesting_collection__pathnames_ssim}#{collection.id}\"", "-_query_:\"{!field f=nesting_collection__parent_ids_ssim}#{collection.id}\""])
      end
    end

    describe 'adding team as subcollection' do
      let(:collection) { team_a }
      let(:nest_direction) { :as_parent }
      it 'should build a query for teams only' do
        subject
        expect(solr_params.fetch(:fq)).to match_array(single_type_as_parent)
      end
    end

    describe 'adding project as a parent collection' do
      let(:collection) { project_a }
      let(:nest_direction) { :as_child }
      it 'should build a query for projects only' do
        subject
        expect(solr_params.fetch(:fq)).to match_array(single_type_as_child)
      end
    end

    describe 'adding another collection type as subcollection' do
      let(:collection) { another }
      let(:nest_direction) { :as_parent }
      it 'should build a query for that collection type only' do
        subject
        expect(solr_params.fetch(:fq)).to match_array(single_type_as_parent)
      end
    end

    describe 'addiing another collection type as a parent collection' do
      let(:collection) { another }
      let(:nest_direction) { :as_child }
      it 'should bulid a query for that collection type only' do
        subject
        expect(solr_params.fetch(:fq)).to match_array(single_type_as_child)
      end
    end
  end
end
