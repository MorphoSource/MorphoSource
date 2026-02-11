require 'rails_helper'
require 'spec_helper'

RSpec.describe Morphosource::Collections::BiologicalSpecimensController, type: :controller do

  describe 'LinkedTeamsControllerBehavior' do
    it 'is included' do
      expect(described_class.ancestors).to include(Morphosource::Collections::LinkedTeamsControllerBehavior)
    end
  end

  describe "search_builder_class" do
    it{ expect(subject.search_builder_class).to eq(Morphosource::Collections::SpecimensSearchBuilder) }
  end

  describe ".configure_facets" do
    let(:facet_fields)  { described_class.blacklight_config.facet_fields}
    before do
      allow_any_instance_of(described_class).to receive(:search_builder_class).and_return("search_builder_class")
      described_class.configure_facets
    end
    describe 'source' do
      subject { facet_fields["record_source"]}
      it 'has a record source facet' do
        expect(subject.label).to eq("Source")
      end
    end
    describe 'organization' do
      subject { facet_fields["organization"]}
      it 'has an organization facet' do
        expect(subject.label).to eq("Organization")
        expect(subject.limit).to eq(10)
      end
    end
    describe 'project' do
      subject { facet_fields["project"] }
      it 'has a project facet' do
        expect(subject.label).to eq("Project")
        expect(subject.limit).to eq(10)
        expect(subject.helper_method).to eq(:collection_title_by_id)
      end
    end
    describe 'team' do
      subject { facet_fields["team"] }
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
      let!(:team) { Collection.create(title: ['Team'], collection_type_gid: team_collection_type.to_global_id) }
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
      let!(:project) { Collection.create(title: ['project'], collection_type_gid: project_collection_type.to_global_id) }
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
      let!(:media_list) { Collection.create(title: ['media_list'], collection_type_gid: media_list_collection_type.to_global_id) }
      before do
        subject.instance_variable_set(:@collection, media_list)
      end
      describe 'search_action_url' do
        it 'is media_list_specimens_path' do
          expect(subject.send(:search_action_url)).to eq(media_list_specimens_path(media_list.id))
        end
      end
      describe 'search_facet_path' do
        it 'is media_list_specimens_facet_path' do
          expect(subject.send(:search_facet_path, {id: facet_id})).to eq(media_list_specimens_facet_path(media_list.id, id: facet_id))
        end
      end
    end
    context 'collection is a sequential section list' do
      let!(:sequential_section_list) { Collection.create(title: ['sequential_section_list'], collection_type_gid: sequential_section_list_collection_type.to_global_id) }
      before do
        subject.instance_variable_set(:@collection, sequential_section_list)
      end
      describe 'search_action_url' do
        it 'is sequential_section_list_specimens_path' do
          expect(subject.send(:search_action_url)).to eq(sequential_section_list_specimens_path(sequential_section_list.id))
        end
      end
      describe 'search_facet_path' do
        it 'is sequential_section_list_specimens_facet_path' do
          expect(subject.send(:search_facet_path, {id: facet_id})).to eq(sequential_section_list_specimens_facet_path(sequential_section_list.id, id: facet_id))
        end
      end
    end
    context 'collection is an organization' do
      let(:depositor)     { FactoryBot.create(:contributor) }
      let!(:organization) { FactoryBot.create(:organization_collection, depositor: depositor.ms_id) }
      before do
        subject.instance_variable_set(:@collection, organization)
      end
      describe 'search_action_url' do
        it 'is organization_specimens_path' do
          expect(subject.send(:search_action_url)).to eq("/organizations/#{organization.id}/biological-specimens?locale=en")
        end
      end
      describe 'search_facet_path' do
        it 'is organization_specimens_facet_path' do
          expect(subject.send(:search_facet_path, {id: facet_id})).to eq("/organizations/#{organization.id}/biological-specimens/facet/#{facet_id}?locale=en")
        end
      end
    end
  end

  # helpers/morphosource/my/works_helper
  describe '#search_action_for_dashboard' do
    let(:main_app)    { Rails.application.routes.url_helpers }
    let(:params)      { { controller: controller.controller_path } }
    let(:collection)  { double('collection', id: 'abc') }
    subject           { controller.view_context }

    before do
      allow(subject).to receive(:params).and_return(params)
      subject.instance_variable_set(:@collection, collection)
      [:project?, :team?, :media_list?, :sequential_section_list?, :organization_collection?].each do |type|
        allow(collection).to receive(type).and_return(false)
      end
    end

    context 'collection is a team' do
      before do
        allow(collection).to receive(:team?).and_return(true)
      end
      it { expect(subject.search_action_for_dashboard).to eq(main_app.team_specimens_path(id: collection.id, locale: 'en')) }
    end

    context 'collection is a project' do
      before do
        allow(collection).to receive(:project?).and_return(true)
      end
      it { expect(subject.search_action_for_dashboard).to eq(main_app.project_specimens_path(id: collection.id, locale: 'en')) }
    end

    context 'collection is a media list' do
      before do
        allow(collection).to receive(:media_list?).and_return(true)
      end
      it { expect(subject.search_action_for_dashboard).to eq(main_app.media_list_specimens_path(id: collection.id, locale: 'en')) }
    end

    context 'collection is a sequential section list' do
      before do
        allow(collection).to receive(:sequential_section_list?).and_return(true)
      end
      it { expect(subject.search_action_for_dashboard).to eq(main_app.sequential_section_list_specimens_path(id: collection.id, locale: 'en')) }
    end

    context 'collection is an organization' do
      before do
        allow(collection).to receive(:organization_collection?).and_return(true)
      end
      it { expect(subject.search_action_for_dashboard).to eq(main_app.organization_specimens_path(id: collection.id, locale: 'en')) }
    end
  end

  describe 'allowed_sort_parameters' do
    let(:allowed_sort_params) do
      ['date_uploaded_dtsi asc',
       'date_uploaded_dtsi desc',
       'record_source_si asc',
       'record_source_si desc',
       'taxonomy_name_si asc',
       'taxonomy_name_si desc',
       'title_ssi asc',
       'title_ssi desc']
    end

    it 'includes custom sort parameters' do
      expect(subject.allowed_sort_parameters).to match_array(allowed_sort_params)
    end
  end
end