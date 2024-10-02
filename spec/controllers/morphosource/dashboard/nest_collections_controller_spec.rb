require 'rails_helper'

RSpec.describe Morphosource::Dashboard::NestCollectionsController, type: :controller do

  include Rails.application.routes.url_helpers

  let(:main_app)      { Rails.application.routes.url_helpers }
  let(:user)          { FactoryBot.create(:contributor) }
  let(:manager)       { FactoryBot.create(:contributor) }
  let(:editor)        { FactoryBot.create(:contributor) }
  let(:downloader)    { FactoryBot.create(:registered_user) }
  let(:viewer)        { FactoryBot.create(:registered_user) }
  let(:depositor)     { FactoryBot.create(:contributor) }

  let(:project)       { FactoryBot.create(:project, depositor: user.ms_id)}
  let(:team)          { FactoryBot.create(:team, depositor: user.ms_id) }
  let(:organization)  { FactoryBot.create(:organization_collection, depositor: user.ms_id)}

  let!(:contributor_role) { Role.create(name: 'contributor') }

  before do
    team.create_collection_groups
    organization.create_collection_groups
    project.create_collection_groups
    Morphosource::Collections::PermissionsCreateService.create_default(collection: team)
    Morphosource::Collections::PermissionsCreateService.create_default(collection: organization)
    Morphosource::Collections::PermissionsCreateService.create_default(collection: project)
  end

  describe 'create_collection_under' do
    context 'collection is a team' do
      context 'user is not authorized to edit the team' do
        it 'redirects to root' do
          post :create_collection_under, params: { parent_id: team.id }
          expect_cancan_access_denied
        end
      end

      context 'user is authorized' do
        before do
          team.managers << manager
          team.managers_group.save
          sign_in User.find(manager.id)
        end

        it 'redirects to create collection' do
          post :create_collection_under, params: { parent_id: team.id }
          expect(response).to redirect_to(new_project_path(parent_id: team.id, locale: 'en'))
        end
      end
    end

    context 'collection is an organization' do
      context 'user is not authorized to edit the team' do
        it 'redirects to root' do
          post :create_collection_under, params: { parent_id: organization.id }
          expect_cancan_access_denied
        end
      end

      context 'user is authorized' do
        before do
          organization.managers << manager
          organization.managers_group.save
          sign_in manager
        end
        it 'redirects to create collection' do
          post :create_collection_under, params: { parent_id: organization.id }
          expect(response).to redirect_to(new_project_path(parent_id: organization.id, locale: 'en'))
        end
      end
    end
  end

  context 'tests prev associated with hyrax version of controller' do
    let(:params)        { { parent_id: parent.id, child_id: project.id } }

    before do
      project.create_collection_groups
      parent.create_collection_groups
      parent.managers << manager
      parent.editors << editor
      parent.depositors << depositor
      parent.downloaders << downloader
      parent.viewers << viewer
      parent.user_groups.each(&:save)
    end

    describe 'create_relationship_under' do
      let(:parent)  { team }

      context 'user is not authorized to edit both parent and child' do
        it 'redirects to root with not found or unavailable flash' do
          post :create_relationship_under, params: params
          expect_cancan_access_denied
        end
      end

      context 'parent is a team' do
        context 'user is authorized' do
          before do
            project.managers << manager
            project.managers_group.save
            sign_in manager
          end

          context 'nesting does not work' do
            before do
              allow(Hyrax::Collections::NestedCollectionPersistenceService).to receive(:persist_nested_collection_for).with(anything()).and_return(false)
            end

            it 'redirects with an error' do
              post :create_relationship_under, params: params
              expect(subject.flash[:alert]).to eq("There was an error. #{project.title.first} was not added to #{parent.title.first}")
              expect(response).to redirect_to(main_app.team_projects_path(parent.id, locale: 'en'))
            end
          end

          context 'nesting works' do
            it 'nests the project under the team and duplicates the team members and roles' do
              post :create_relationship_under, params: params
              expect(project.reload.parent_id).to eq(parent.id)
              expect(project.managers).to include(manager)
              expect(project.managers).to include(user)
              expect(project.editors).to match_array([editor])
              expect(project.depositors).to match_array([depositor])
              expect(project.downloaders).to match_array([downloader])
              expect(project.viewers).to match_array([viewer])
              expect(subject.flash[:notice]).to eq("\'#{project.title.first}\' has been added to \'#{parent.title.first}\'")
              expect(response).to redirect_to(main_app.team_projects_path(parent.id, locale: 'en'))
            end
          end
        end
      end
    end

    describe 'remove_relationship_under' do
      let(:parent)  { team }

      context 'user is not authorized to edit the parent' do
        it 'redirects to root with not found or unavailable flash' do
          post :remove_relationship_under, params: params
          expect_cancan_access_denied
        end
      end

      context 'parent is a team' do
        context 'user is authorized' do
          before do
            project.managers << manager
            project.managers_group.save
            sign_in manager

            # create relationship to be removed
            post :create_relationship_under, params: params
          end
          it 'removes the project from the team and team members from project member roles' do
            # check that project is nested in team corrrectly before removing it
            expect(project.reload.parent_id).to eq(parent.id)
            expect(project.managers).to match_array([user, manager])
            expect(project.editors).to match_array([editor])
            expect(project.depositors).to match_array([depositor])
            expect(project.downloaders).to match_array([downloader])
            expect(project.viewers).to match_array([viewer])

            post :remove_relationship_under, params: params
            expect(project.reload.parent_id).to eq(nil)
            expect(project.managers).to match_array([manager])
            expect(project.editors).to match_array([])
            expect(project.depositors).to match_array([])
            expect(project.downloaders).to match_array([])
            expect(project.viewers).to match_array([])

            expect(subject.flash[:notice]).to eq("\'#{project.title.first}\' has been removed from \'#{parent.title.first}\'")
            expect(response).to redirect_to(main_app.team_projects_path(parent.id, locale: 'en'))
          end
        end
      end
    end
  end
end
