# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Morphosource::Dashboard::CollectionsControllerBehavior, type: :controller do

  describe 'collection type specific methods' do
    before do
      allow(subject).to receive(:params).and_return(params)
    end
    context 'Team' do
      let(:params)  { ActionController::Parameters.new("collection" => { "title" => "team title", "members" => "team members", "representative_id" => "team representative_id" } ) }
      subject  { Morphosource::Dashboard::Collections::TeamsController.new }

      it 'has the correct values' do
        expect(subject.send(:snake_case_collection_class)).to eq(:collection)
        expect(subject.send(:collection_params)["title"]).to match_array([params["collection"]["title"]])
        expect(subject.send(:member_params)).to eq(params["collection"]["members"])
        expect(subject.send(:thumbnail_params)).to eq(params["collection"]["representative_id"])
      end
    end

    context 'Project' do
      let(:params)  { ActionController::Parameters.new("collection" => { "title" => "project title", "members" => "project members", "representative_id" => "project representative_id" } ) }
      subject  { Morphosource::Dashboard::Collections::ProjectsController.new }
      it 'has the correct values' do
        expect(subject.send(:snake_case_collection_class)).to eq(:collection)
        expect(subject.send(:collection_params)["title"]).to match_array([params["collection"]["title"]])
        expect(subject.send(:member_params)).to eq(params["collection"]["members"])
        expect(subject.send(:thumbnail_params)).to eq(params["collection"]["representative_id"])
      end
    end

    context 'Media List' do
      let(:params)  { ActionController::Parameters.new("media_list" => { "title" => "list title", "members" => "list members", "representative_id" => "list representative_id" } ) }
      subject  { Morphosource::Dashboard::Collections::MediaListsController.new }
      it 'has the correct values' do
        expect(subject.send(:snake_case_collection_class)).to eq(:media_list)
        expect(subject.send(:collection_params)["title"]).to match_array([params["media_list"]["title"]])
        expect(subject.send(:member_params)).to eq(params["media_list"]["members"])
        expect(subject.send(:thumbnail_params)).to eq(params["media_list"]["representative_id"])
      end
    end

    context 'Sequential Section List' do
      let(:params)  { ActionController::Parameters.new("sequential_section_list" => { "title" => "list title", "members" => "list members", "representative_id" => "list representative_id" } ) }
      subject  { Morphosource::Dashboard::Collections::MediaLists::SequentialSectionListsController.new }
      it 'has the correct values' do
        expect(subject.send(:snake_case_collection_class)).to eq(:sequential_section_list)
        expect(subject.send(:collection_params)["title"]).to match_array([params["sequential_section_list"]["title"]])
        expect(subject.send(:member_params)).to eq(params["sequential_section_list"]["members"])
        expect(subject.send(:thumbnail_params)).to eq(params["sequential_section_list"]["representative_id"])
      end
    end

    context 'Organization' do
      let(:params)  { ActionController::Parameters.new("organization_collection" => { "title" => "organization title", "members" => "organization members", "representative_id" => "organization representative_id" } ) }
      subject  { Morphosource::Dashboard::Collections::OrganizationCollectionsController.new }
      it 'has the correct values' do
        expect(subject.send(:snake_case_collection_class)).to eq(:organization_collection)
        expect(subject.send(:collection_params)["title"]).to match_array([params["organization_collection"]["title"]])
        expect(subject.send(:member_params)).to eq(params["organization_collection"]["members"])
        expect(subject.send(:thumbnail_params)).to eq(params["organization_collection"]["representative_id"])
      end
    end
  end
end