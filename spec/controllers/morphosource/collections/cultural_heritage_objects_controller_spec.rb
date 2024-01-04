require 'rails_helper'
require 'spec_helper'

RSpec.describe Morphosource::Collections::CulturalHeritageObjectsController, type: :controller do

  describe 'LinkedTeamsControllerBehavior' do
    it 'is included' do
      expect(described_class.ancestors).to include(Morphosource::Collections::LinkedTeamsControllerBehavior)
    end
  end

  describe "search_builder_class" do
    it{ expect(subject.search_builder_class).to eq(Morphosource::Collections::ChosSearchBuilder) }
  end

  describe ".configure_facets" do
    let(:facet_fields)  { described_class.blacklight_config.facet_fields}
    before do
      allow_any_instance_of(described_class).to receive(:search_builder_class).and_return("search_builder_class")
      described_class.configure_facets
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
    it {expect(subject.send(:tab)).to eq(:chos) }
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
      it { expect(subject.search_action_for_dashboard).to eq(main_app.team_chos_path(id: collection.id, locale: 'en')) }
    end

    context 'collection is a project' do
      before do
        allow(collection).to receive(:project?).and_return(true)
      end
      it { expect(subject.search_action_for_dashboard).to eq(main_app.project_chos_path(id: collection.id, locale: 'en')) }
    end

    context 'collection is a media list' do
      before do
        allow(collection).to receive(:media_list?).and_return(true)
      end
      it { expect(subject.search_action_for_dashboard).to eq(main_app.media_list_chos_path(id: collection.id, locale: 'en')) }
    end

    context 'collection is a sequential section list' do
      before do
        allow(collection).to receive(:sequential_section_list?).and_return(true)
      end
      it { expect(subject.search_action_for_dashboard).to eq(main_app.sequential_section_list_chos_path(id: collection.id, locale: 'en')) }
    end

    context 'collection is an organization' do
      before do
        allow(collection).to receive(:organization_collection?).and_return(true)
      end
      it { expect(subject.search_action_for_dashboard).to eq(main_app.organization_chos_path(id: collection.id, locale: 'en')) }
    end
  end
end
