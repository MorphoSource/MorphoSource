# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Morphosource::Dashboard::Collections::OrganizationCollectionsController, type: :controller do

  describe 'temporary admin-only restriction' do
    let(:depositor)     { FactoryBot.create(:contributor) }
    let!(:organization) { FactoryBot.create(:organization_collection, visibility: 'open', depositor: depositor.ms_id) }
    let(:params)        { { id: organization.id } }

    before do
      sign_in user
    end

    context 'user is an admin' do
      let(:user)  { FactoryBot.create(:admin) }

      it 'responds with a 200' do
        get :edit, params: params
        expect(response.status).to eq(200)
        get :members, params: params
        expect(response.status).to eq(200)
        get :new
        expect(response.status).to eq(200)
        post :create, params: { "organization_collection" => { "title" => ['organization'] } }
        expect(response.status).to eq(200)
        put :update, params: { "organization_collection" => { "id" => organization.id } }
        expect(response.status).to eq(200)
        patch :update, params: { "organization_collection" => { "id" => organization.id } }
        expect(response.status).to eq(200)
        get :files, params: params
        expect(response.status).to eq(200)
      end
    end

    context 'user is not an admin' do
      let(:user)  { depositor }

      it 'responds with a redirect' do
      get :edit, params: params
        expect(response.status).to eq(302)
        get :members, params: params
        expect(response.status).to eq(302)
        get :new
        expect(response.status).to eq(302)
        post :create, params: { "organization_collection" => { "title" => ['organization'] } }
        expect(response.status).to eq(302)
        put :update, params: { "organization_collection" => { "id" => organization.id } }
        expect(response.status).to eq(302)
        patch :update, params: { "organization_collection" => { "id" => organization.id } }
        expect(response.status).to eq(302)
        get :files, params: params
        expect(response.status).to eq(302)
      end
    end
  end

  describe 'presenter_class' do
    it { expect(controller.presenter_class).to be(Morphosource::Collections::OrganizationPresenter) }
  end

  describe 'form_class' do
    it { expect(controller.form_class).to be(Morphosource::Forms::Collections::OrganizationForm) }
  end

  describe 'default_collection_type' do
    let!(:organization_collection_type) { Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::Organizations::SETTINGS) }

    it { expect(subject.send(:default_collection_type)).to eq(organization_collection_type) }
  end

  describe 'collection_class' do
    it { expect(subject.send(:collection_class)).to eq(OrganizationCollection) }
  end
end
