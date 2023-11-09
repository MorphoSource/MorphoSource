require 'rails_helper'
require 'spec_helper'
include ActionDispatch::TestProcess
include Warden::Test::Helpers

RSpec.describe Morphosource::CollectionsController, type: :controller do
  let(:user)                                    { User.create(email: 'user@email.com', password: 'password') }
  let(:depositor) { User.create(email: 'depositor@email.com', password: 'password') }
  let(:team)                                    { Collection.create(title: ['team'], collection_type_gid: team_collection_type.gid, depositor: depositor.ms_id) }
  let(:project)                                 { Collection.create(title: ['project'], collection_type_gid: project_collection_type.gid, depositor: depositor.ms_id) }
  let(:media_list)                              { MediaList.create(title: ['media list'], visibility: 'open', collection_type_gid: media_list_collection_type.gid, depositor: depositor.ms_id) }
  let(:sequential_section_list)                 { SequentialSectionList.create(title: ['sequential section list'], visibility: 'open', collection_type_gid: sequential_section_list_collection_type.gid, depositor: depositor.ms_id) }

  before do
    team.create_collection_groups
    project.create_collection_groups
    Morphosource::Collections::PermissionsCreateService.create_default(collection: team)
    Morphosource::Collections::PermissionsCreateService.create_default(collection: project)
  end

  describe "search_builder_class" do
    it { expect(subject.search_builder_class).to eq(Morphosource::Collections::MediaSearchBuilder) }
  end

  describe ".configure_facets" do
    let(:facet_fields)  { described_class.blacklight_config.facet_fields}
    before do
      allow_any_instance_of(described_class).to receive(:search_builder_class).and_return("search_builder_class")
      described_class.configure_facets
    end

    describe 'media type' do
      subject { facet_fields["media_type"]}
      it 'has a media type facet' do
        expect(subject.label).to eq("Media Type")
        expect(subject.limit).to eq(10)
      end
    end

    describe 'object' do
      subject { facet_fields["object"]}
      it 'has an object facet' do
        expect(subject.label).to eq("Object")
        expect(subject.limit).to eq(10)
      end
    end
    
    describe 'organization' do
      subject { facet_fields["organization"]}
      it 'has an organization facet' do
        expect(subject.label).to eq("Organization")
        expect(subject.limit).to eq(10)
      end
    end

    describe 'publication status' do
      subject { facet_fields["publication_status"]}
      it 'has a publication status facet' do
        expect(subject.label).to eq("Publication Status")
        expect(subject.limit).to eq(10)
      end
    end

    describe 'taxonomy_name' do
      subject { facet_fields["taxonomy_name"]}
      it 'has a taxonomy (name) facet' do
        expect(subject.label).to eq("Taxonomy (Name)")
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
    describe 'data manager' do
      subject { facet_fields["owner"] }
      it 'has a data manager facet' do
        expect(subject.label).to eq("Data Manager")
        expect(subject.limit).to eq(10)
      end
    end
    describe 'depositor' do
      subject { facet_fields["depositor"] }
      it 'has a depositor facet' do
        expect(subject.label).to eq("Data Uploader")
        expect(subject.limit).to eq(10)
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
    describe 'calling other methods' do
      before do
        team.visibility = 'open'
        team.save!
      end
      it do
        expect(subject).to receive(:presenter)
        expect(subject).to receive(:query_solr)
        expect(subject).to receive(:query_collection_counts)
        expect(subject).to receive(:query_collection_members)
        get :show, params: { id: team.id }
      end
    end
  end

  describe '#about' do
    before do
      allow(subject).to receive(:redirect_to_collection_type).and_return(true)
    end
    describe 'access' do
      context 'collection is public' do
        before do
          team.visibility = 'open'
          team.save!
          get :about, params: { id: team.id }
        end
        it { expect(response.status).to eq(200) }
      end
      context 'collection is private' do
        context 'user is not signed in' do
          before do
            get :about, params: { id: team.id }
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
              get :about, params: { id: team.id }
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
              get :about, params: { id: team.id }
            end
            it { expect(response.status).to eq(200) }
          end
        end
      end
    end
    describe 'calling other methods' do
      before do
        team.visibility = 'open'
        team.save!
      end
      it do
        expect(subject).to receive(:presenter)
        expect(subject).to receive(:query_collection_counts)
        expect(subject).to receive(:query_collection_members)
        get :show, params: { id: team.id }
      end
    end
  end

  describe 'load_collection' do
    before do
      team.visibility = 'open'
      team.save
      allow(subject).to receive(:params).and_return({:id => team.id})
    end
    it 'finds the collection' do
      subject.send(:load_collection)
      expect(subject.instance_variable_get(:@curation_concern)).to eq(team)
      expect(subject.instance_variable_get(:@collection)).to eq(team)
    end
  end

  describe 'tab' do
    it {expect(subject.send(:tab)).to eq(:media) }
  end

  describe 'remove_constraint_url' do
    context 'collection is a team' do
      let(:params)  { { id: team.id,
                      q: 'term',
                      f: ActionController::Parameters.new( {"human_readable_media_type_ssim"=>["Image"]}),
                      controller: "morphosource/collections/teams" }}
      it 'is the team remove constraints url' do
        expect(subject.send(:remove_constraint_url, params)).to include("/teams/#{team.id}?f%5Bhuman_readable_media_type_ssim%5D%5B%5D=Image&locale=en")
      end
    end
    context 'collection is a project' do
      let(:params)  { { id: project.id,
                      q: 'term',
                      f: ActionController::Parameters.new( {"human_readable_media_type_ssim"=>["Image"]}),
                      controller: "morphosource/collections/projects" }}
      it 'is the project remove constraints url' do
        expect(subject.send(:remove_constraint_url, params)).to include("/projects/#{project.id}?f%5Bhuman_readable_media_type_ssim%5D%5B%5D=Image&locale=en")
      end
    end
    context 'collection is a media list' do
      let(:params)  { { id: media_list.id,
                      q: 'term',
                      f: ActionController::Parameters.new( {"human_readable_media_type_ssim"=>["Image"]}),
                      controller: "morphosource/collections/media_lists" }}
      it 'is the media list remove constraints url' do
        expect(subject.send(:remove_constraint_url, params)).to include("/media_lists/#{media_list.id}?f%5Bhuman_readable_media_type_ssim%5D%5B%5D=Image&locale=en")
      end
    end
    context 'collection is a sequential section list' do
      let(:params)  { { id: sequential_section_list.id,
                      q: 'term',
                      f: ActionController::Parameters.new( {"human_readable_media_type_ssim"=>["Image"]}),
                      controller: "morphosource/collections/media_lists/sequential_section_lists" }}
      it 'is the sequential section list remove constraints url' do
        expect(subject.send(:remove_constraint_url, params)).to include("/sequential_section_lists/#{sequential_section_list.id}?f%5Bhuman_readable_media_type_ssim%5D%5B%5D=Image&locale=en")
      end
    end
  end
end
