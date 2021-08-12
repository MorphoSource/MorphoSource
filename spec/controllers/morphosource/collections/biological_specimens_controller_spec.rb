require 'rails_helper'
require 'spec_helper'
include ActionDispatch::TestProcess
include Warden::Test::Helpers

RSpec.describe Morphosource::Collections::BiologicalSpecimensController, type: :controller do
  let(:user)                    { User.create(email: 'user@email.com', password: 'password') }
  let(:depositor) { User.create(email: 'depositor@email.com', password: 'password') }
  let(:team_collection_type)    { Hyrax::CollectionType.create(title: 'Team') }
  let(:team)                    { Collection.create(title: ['team'], collection_type_gid: team_collection_type.gid, depositor: depositor.ms_id) }
  let(:project_collection_type) { Hyrax::CollectionType.create(title: 'Project') }
  let(:project)                 { Collection.create(title: ['project'], collection_type_gid: project_collection_type.gid, depositor: depositor.ms_id) }

  before do
    team.create_collection_groups
    project.create_collection_groups
  end

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
        expect(subject.limit).to eq(nil)
      end
    end
    describe 'project' do
      subject { facet_fields['media_member_of_project_ids_ssim'] }
      it 'has a project facet' do
        expect(subject.label).to eq("Project")
        expect(subject.limit).to eq(nil)
        expect(subject.helper_method).to eq(:collection_title_by_id)
      end
    end
    describe 'team' do
      subject { facet_fields['media_member_of_team_ids_ssim'] }
      it 'has a team facet' do
        expect(subject.label).to eq("Team")
        expect(subject.limit).to eq(nil)
        expect(subject.helper_method).to eq(:collection_title_by_id)
      end
    end
  end

  describe '#show' do
    before do
      allow(subject).to receive(:redirect_to_collection_type).and_return(true)
    end
    describe 'access' do
      context 'collection is public' do
        before do
          team.visibility = 'open'
          team.save!
          get :show, params: { id: team.id }
        end
        it { expect(response.status).to eq(200) }
      end
      context 'collection is private' do
        context 'user is not signed in' do
          before do
            get :show, params: { id: team.id }
          end
          it 'is unauthorized' do
            expect(response).to redirect_to root_path
            expect(flash[:alert]).to eq('You are not authorized to access this collection.')
          end
        end
        context 'user is signed in' do
          context 'user does not have access' do
            before do
              sign_in user
              get :show, params: { id: team.id }
            end
            it 'is unauthorized' do
              expect(response).to redirect_to root_path
              expect(flash[:alert]).to eq('You are not authorized to access this collection.')
            end
          end
          context 'user has access' do
            before do
              team.read_users += [user.ms_id]
              team.save
              sign_in user
              get :show, params: { id: team.id }
            end
            it { expect(response.status).to eq(200) }
          end
        end
      end
    end
  end

  describe 'tab' do
    it {expect(subject.send(:tab)).to eq(:specimens) }
  end

  describe 'filtered_facets' do
    it 'lists facets to be filtered by access' do
      expect(subject.send(:filtered_facets)).to match_array(["media_member_of_project_ids_ssim", "media_member_of_team_ids_ssim"])
    end
  end
end
