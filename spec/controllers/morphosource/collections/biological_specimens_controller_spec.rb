require 'rails_helper'
require 'spec_helper'

RSpec.describe Morphosource::Collections::BiologicalSpecimensController, type: :controller do

  describe "search_builder_class" do
    it{ expect(subject.search_builder_class).to eq(        Morphosource::Collections::SpecimensSearchBuilder) }
  end

  describe ".configure_facets" do
    let(:facet_fields)  { described_class.blacklight_config.facet_fields}
    before do
      allow_any_instance_of(described_class).to receive(:search_builder_class).and_return("search_builder_class")
      described_class.configure_facets
    end
    describe 'source' do
      subject { facet_fields['record_source_ssim']}
      it 'has a record source facet' do
        expect(subject.label).to eq("Source")
      end
    end
    describe 'organization' do
      subject { facet_fields['organization_ssim']}
      it 'has an organization facet' do
        expect(subject.label).to eq("Organization")
        expect(subject.limit).to eq(10)
      end
    end
    describe 'project' do
      subject { facet_fields['media_member_of_project_ids_ssim'] }
      it 'has a project facet' do
        expect(subject.label).to eq("Project")
        expect(subject.limit).to eq(10)
        expect(subject.helper_method).to eq(:collection_title_by_id)
      end
    end
    describe 'team' do
      subject { facet_fields['media_member_of_team_ids_ssim'] }
      it 'has a team facet' do
        expect(subject.label).to eq("Team")
        expect(subject.limit).to eq(10)
        expect(subject.helper_method).to eq(:collection_title_by_id)
      end
    end
  end

  describe 'tab' do
    it {expect(subject.send(:tab)).to eq(:specimens) }
  end

  describe 'search_action_url, search_facet_path' do
    let(:facet_id)  { 'depositor_ssi' }
    context 'collection is a team' do
      let!(:team_collection_type) { Hyrax::CollectionType.create(title: 'Team', machine_id: 'team') }
      let!(:team) { Collection.create(title: ['Team'], collection_type_gid: team_collection_type.gid) }
      before do
        subject.instance_variable_set(:@collection, team)
      end
      describe 'search_action_url' do
        it 'is team_specimens_path' do
          expect(subject.send(:search_action_url)).to eq("/teams/#{team.id}/biological_specimens?locale=en")
        end
      end
      describe 'search_facet_path' do
        it 'is team_specimens_facet_path' do
          expect(subject.send(:search_facet_path, {id: facet_id})).to eq("/teams/#{team.id}/biological_specimens/facet/#{facet_id}?locale=en")
        end
      end
    end
    context 'collection is a project' do
      let!(:project_collection_type) { Hyrax::CollectionType.create(title: 'project', machine_id: 'project') }
      let!(:project) { Collection.create(title: ['project'], collection_type_gid: project_collection_type.gid) }
      before do
        subject.instance_variable_set(:@collection, project)
      end
      describe 'search_action_url' do
        it 'is project_specimens_path' do
          expect(subject.send(:search_action_url)).to eq("/projects/#{project.id}/biological_specimens?locale=en")
        end
      end
      describe 'search_facet_path' do
        it 'is project_specimens_facet_path' do
          expect(subject.send(:search_facet_path, {id: facet_id})).to eq("/projects/#{project.id}/biological_specimens/facet/#{facet_id}?locale=en")
        end
      end
    end
    context 'collection is a media list' do
      let!(:media_list_collection_type) { Hyrax::CollectionType.create(title: 'media_list', machine_id: 'media_list') }
      let!(:media_list) { Collection.create(title: ['media_list'], collection_type_gid: media_list_collection_type.gid) }
      before do
        subject.instance_variable_set(:@collection, media_list)
      end
      describe 'search_action_url' do
        it 'is media_list_specimens_path' do
          expect(subject.send(:search_action_url)).to eq("/media_lists/#{media_list.id}/biological_specimens?locale=en")
        end
      end
      describe 'search_facet_path' do
        it 'is media_list_specimens_facet_path' do
          expect(subject.send(:search_facet_path, {id: facet_id})).to eq("/media_lists/#{media_list.id}/biological_specimens/facet/#{facet_id}?locale=en")
        end
      end
    end
    context 'collection is a sequential section list' do
      let!(:sequential_section_list_collection_type) { Hyrax::CollectionType.create(title: 'sequential_section_list', machine_id: 'sequential_section_list') }
      let!(:sequential_section_list) { Collection.create(title: ['sequential_section_list'], collection_type_gid: sequential_section_list_collection_type.gid) }
      before do
        subject.instance_variable_set(:@collection, sequential_section_list)
      end
      describe 'search_action_url' do
        it 'is sequential_section_list_specimens_path' do
          expect(subject.send(:search_action_url)).to eq("/sequential_section_lists/#{sequential_section_list.id}/biological_specimens?locale=en")
        end
      end
      describe 'search_facet_path' do
        it 'is sequential_section_list_specimens_facet_path' do
          expect(subject.send(:search_facet_path, {id: facet_id})).to eq("/sequential_section_lists/#{sequential_section_list.id}/biological_specimens/facet/#{facet_id}?locale=en")
        end
      end
    end
  end
end
