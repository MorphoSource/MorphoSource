# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Morphosource::Dashboard::Collections::OrganizationCollectionsController, type: :controller do

  let(:depositor)     { User.create(email: 'depositor@email.com', password: 'password') }
  let!(:organization) { FactoryBot.create(:organization_collection, visibility: 'open', depositor: depositor.ms_id) }
  let(:params)        { { id: organization.id } }
  let(:user)          { depositor }

  before do
    Morphosource::Collections::PermissionsCreateService.create_default(collection: organization)
    sign_in user
  end

  describe 'temporary admin-only restriction' do
    context 'user is an admin' do
      let(:user)  { FactoryBot.create(:admin) }

      before do
        allow(Collection).to receive(:find).and_call_original
      end

      it 'responds with a 200 or a redirect' do
        get :edit, params: params
        expect(response.status).to eq(200)
        get :members, params: params
        expect(response.status).to eq(200)
        get :permissions, params: params
        expect(response.status).to eq(200)
        get :projects, params: params
        expect(response.status).to eq(200)
        get :new
        expect(response.status).to eq(200)
        post :create, params: { "organization_collection" => { "title" => 'organization' } }
        expect(response).to redirect_to(organization_edit_path(OrganizationCollection.last))
        put :update, params: { "id" => organization.id, "organization_collection" => { "title" => "new title" } }
        expect(response).to redirect_to(organization_path(organization))
        put :update, params: { "id" => organization.id, "update_remote_file_submission_settings" => "true","organization_collection" => { "title" => "new title" } }
        expect(response).to redirect_to(organization_permissions_path(organization))
        patch :update, params: { "id" => organization.id, "organization_collection" => { "title" => "new title" } }
        expect(response).to redirect_to(organization_path(organization))
        put :update, params: { "id" => organization.id, "update_remote_file_submission_settings" => "true","organization_collection" => { "title" => "new title" } }
        expect(response).to redirect_to(organization_permissions_path(organization))
        get :files, params: params
        expect(response.status).to eq(200)
      end
    end

    context 'user is an organization manager' do
      before do
        organization.managers << user
        organization.managers_group.save
      end

      it 'responds with a redirect or 200' do
        get :edit, params: params
        expect(response.status).to eq(200)
        get :members, params: params
        expect(response.status).to eq(200)
        byebug
        get :permissions, params: params
        expect(response.status).to eq(200)
        byebug
        get :projects, params: params
        expect(response.status).to eq(200)
        get :new
        expect(response.status).to redirect_to(root_path)
        post :create, params: { "organization_collection" => { "title" => 'organization' } }
        expect(response.status).to redirect_to(root_path)
        put :update, params: { "id" => organization.id, "organization_collection" => { "title" => "new title" } }
        expect(response).to redirect_to(organization_path(organization))
        put :update, params: { "id" => organization.id, "update_remote_file_submission_settings" => "true","organization_collection" => { "title" => "new title" } }
        expect(response).to redirect_to(organization_permissions_path(organization))
        patch :update, params: { "id" => organization.id, "organization_collection" => { "title" => "new title" } }
        expect(response).to redirect_to(organization_path(organization))
        put :update, params: { "id" => organization.id, "update_remote_file_submission_settings" => "true","organization_collection" => { "title" => "new title" } }
        expect(response).to redirect_to(organization_permissions_path(organization))
        get :files, params: params
        expect(response.status).to eq(200)
      end
    end
  end

  describe 'presenter_class' do
    it { expect(controller.presenter_class).to be(Morphosource::Collections::OrganizationPresenter) }
  end

  describe 'form_class' do
    it { expect(controller.form_class).to be(Morphosource::Forms::Collections::OrganizationCollectionForm) }
  end

  describe 'default_collection_type' do
    let!(:organization_collection_type) { Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::Organizations::SETTINGS) }

    it { expect(subject.send(:default_collection_type)).to eq(organization_collection_type) }
  end

  describe 'collection_class' do
    it { expect(subject.send(:collection_class)).to eq(OrganizationCollection) }
  end

  describe 'permissions_path' do
    it 'is the organization_permissions_path' do
      subject.instance_variable_set(:@organization, organization)
      expect(subject.send(:permissions_path)).to eq(organization_permissions_path(organization))
    end
  end
end
