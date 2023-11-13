require 'rails_helper'

RSpec.describe Hyrax::Dashboard::NestCollectionsController, type: :controller do
  routes { Hyrax::Engine.routes }

  let(:user)                    { User.create(email: 'user@email.com', password: 'password') }
  let(:team)                    { Collection.create(title: ['Team'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id) }
  let(:project)                 { Collection.create(title: ['Project'], collection_type_gid: project_collection_type.gid, depositor: user.ms_id) }
  let(:manager)                 { User.create(email: 'manager@email.com', password: 'password') }
  let(:editor)                  { User.create(email: 'editor@email.com', password: 'password') }
  let(:depositor)               { User.create(email: 'depositor@email.com', password: 'password') }
  let(:downloader)              { User.create(email: 'downloader@email.com', password: 'password') }
  let(:viewer)                  { User.create(email: 'viewer@email.com', password: 'password') }
  let(:params)                  { { parent_id: team.id, child_id: project.id } }

  before do
    team.create_collection_groups
    project.create_collection_groups
    team.managers << manager
    team.managers_group.save
    team.editors << editor
    team.editors_group.save
    team.depositors << depositor
    team.depositors_group.save
    team.downloaders << downloader
    team.downloaders_group.save
    team.viewers << viewer
    team.viewers_group.save

    sign_in user
  end

  describe 'create_relationship_under' do
    context 'user is not authorized to edit both parent and child' do
      it 'redirects to root with not found or unavailable flash' do
        post :create_relationship_under, params: params
        expect(response.status).to eq(302)
      end
    end
    context 'user is authorized' do
      before do
        Morphosource::Collections::PermissionsCreateService.create_default(collection: team)
        Morphosource::Collections::PermissionsCreateService.create_default(collection: project)
      end
      context 'nesting does not work' do
        before do
          allow(Hyrax::Collections::NestedCollectionPersistenceService).to receive(:persist_nested_collection_for).with(anything()).and_return(false)
        end
        it 'redirects with an error' do
          post :create_relationship_under, params: params
          expect(subject.flash[:alert]).to eq("There was an error. #{project.title.first} was not added to #{team.title.first}")
          expect(response).to redirect_to(Rails.application.routes.url_helpers.team_projects_path(team.id, locale: 'en'))
        end
      end
      context 'nesting works' do
        it 'nests the project under the team and duplicates the team members and roles' do
          post :create_relationship_under, params: params
          expect(project.reload.parent_id).to eq(team.id)
          expect(project.managers).to match_array([user, manager])
          expect(project.editors).to match_array([editor])
          expect(project.depositors).to match_array([depositor])
          expect(project.downloaders).to match_array([downloader])
          expect(project.viewers).to match_array([viewer])
          expect(subject.flash[:notice]).to eq("\'#{project.title.first}\' has been added to \'#{team.title.first}\'")
          expect(response).to redirect_to(Rails.application.routes.url_helpers.team_projects_path(team.id, locale: 'en'))
        end
      end
    end
  end

  describe 'remove_relationship_under' do
    context 'user is not authorized to edit the parent' do
      it 'redirects to root with not found or unavailable flash' do
        post :remove_relationship_under, params: params
        expect(response.status).to eq(302)
      end
    end
    context 'user is authorized' do
      before do
        Morphosource::Collections::PermissionsCreateService.create_default(collection: team)
        Morphosource::Collections::PermissionsCreateService.create_default(collection: project)
        sign_in user
        # create relationship to be removed
        post :create_relationship_under, params: params
      end
      it 'removes the project from the team and team members from project member roles' do
        # check that project is nested in team corrrectly before removing it
        expect(project.reload.parent_id).to eq(team.id)
        expect(project.managers).to match_array([user, manager])
        expect(project.editors).to match_array([editor])
        expect(project.depositors).to match_array([depositor])
        expect(project.downloaders).to match_array([downloader])
        expect(project.viewers).to match_array([viewer])

        post :remove_relationship_under, params: params
        expect(project.reload.parent_id).to eq(nil)
        expect(project.managers).to match_array([user])
        expect(project.editors).to match_array([])
        expect(project.depositors).to match_array([])
        expect(project.downloaders).to match_array([])
        expect(project.viewers).to match_array([])

        expect(subject.flash[:notice]).to eq("\'#{project.title.first}\' has been removed from \'#{team.title.first}\'")
        expect(response).to redirect_to(Rails.application.routes.url_helpers.team_projects_path(team.id, locale: 'en'))
      end
    end
  end
end
