require 'rails_helper'
require 'spec_helper'
include ActionDispatch::TestProcess
include Warden::Test::Helpers

RSpec.describe Morphosource::CollectionsController, type: :controller do
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
    it{ expect(subject.search_builder_class).to eq(        Morphosource::Collections::MediaSearchBuilder) }
  end

  describe 'redirect_to_collection_type' do
    before do
      team.visibility = 'open'
      project.visibility = 'open'
      [team, project].each(&:save)
    end
    context 'request includes /collections/' do
      context 'collection is a team' do
        before do
          allow(subject).to receive(:params).and_return({:id => team.id})
        end
        it 'redirects to the teams controller' do
          get :show, params: { id: team.id }
          expect(response).to redirect_to(team_media_path(request.parameters))
        end
      end
      context 'collection is a project' do
        before do
          allow(subject).to receive(:params).and_return({:id => project.id})
        end
        it 'redirects to the projects controller' do
          get :show, params: { id: project.id }
          expect(response).to redirect_to(project_media_path(request.parameters))
        end
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

  describe 'redirect_to_collection_type' do
    context 'collection is a team' do
      before do
        team.visibility = 'open'
        team.save
      end
      it 'redirects to the team url' do
        get :show, params: { id: team.id }
        expect(response).to redirect_to(team_media_path(request.parameters))
      end
    end
    context 'collection is a project' do
      before do
        project.visibility = 'open'
        project.save
      end
      it 'redirects to the project url' do
        get :show, params: { id: project.id }
        expect(response).to redirect_to(project_media_path(request.parameters))
      end
    end
  end

  describe 'tab' do
    it {expect(subject.send(:tab)).to eq(:media) }
  end
end
