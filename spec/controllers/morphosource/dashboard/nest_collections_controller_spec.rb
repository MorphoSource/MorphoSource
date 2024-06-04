require 'rails_helper'

RSpec.describe Morphosource::Dashboard::NestCollectionsController, type: :controller do

  include Rails.application.routes.url_helpers

  let(:main_app)      { Rails.application.routes.url_helpers }
  let(:user)          { User.create(email: 'user@email.com', password: 'password') }
  let(:depositor)     { FactoryBot.create(:contributor) }
  let(:team)          { FactoryBot.create(:team, depositor: depositor.ms_id) }
  let(:organization)  { FactoryBot.create(:organization_collection, depositor: depositor.ms_id)}
  let!(:contributor_role) { Role.create(name: 'contributor') }

  before do
    team.create_collection_groups
    Morphosource::Collections::PermissionsCreateService.create_default(collection: team)
    Morphosource::Collections::PermissionsCreateService.create_default(collection: organization)
    user.make_contributor
    sign_in user
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
          team.managers << user
          team.managers_group.save
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
          organization.managers << user
          organization.managers_group.save
        end
        it 'redirects to create collection' do
          post :create_collection_under, params: { parent_id: organization.id }
          expect(response).to redirect_to(new_project_path(parent_id: organization.id, locale: 'en'))
        end
      end
    end
  end
end
