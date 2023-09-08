# frozen_string_literal: true
require 'rails_helper'
require 'morphosource/dashboard/collections_controller'
require 'hyrax/dashboard/collections_controller'
require 'hyrax/forms/collection_form'

RSpec.describe Morphosource::Dashboard::CollectionsController, type: :controller do

  let(:contributor)             { FactoryBot.create(:contributor) }
  let(:another_collection_type) { Hyrax::CollectionType.create(title: 'Another') }
  let(:collection_params)       { { collection: { title: 'New Collection' } } }
  let(:main_app)                { Rails.application.routes.url_helpers }
  let(:user)                    { contributor }

  before do
    sign_in user
    allow(subject).to receive(:current_user).and_return(user)
  end

  describe 'new' do
    context 'user is an admin' do
      let(:user)  { FactoryBot.create(:admin) }

      it 'returns a 200' do
        get :new
        expect(response.status).to eq(200)
      end
    end

    context 'user is a contributor' do
      it 'returns a 200' do
        get :new
        expect(response.status).to eq(200)
      end
    end

    context 'user is a registered user' do
      let(:user)  { FactoryBot.create(:registered_user) }

      it 'is unauthorized' do
        get :new
        expect(response).to redirect_to main_app.root_path(locale: 'en')
        expect(flash[:alert]).to eq('You are not authorized to access this page.')
      end
    end

    context 'user is a guest user' do
      before do
        sign_out user
      end
      it 'is unauthorized' do
        get :new
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end
  end

  describe '#after_create' do
    context 'The collection is a team' do
      it 'calls set_morphosource_permissions' do
        expect(subject).to receive(:set_morphosource_permissions)
        post :create, params: collection_params.merge(collection_type_gid: team_collection_type.gid)
      end
    end

    context 'The collection is a project' do
      it 'calls set_morphosource_permissions' do
        expect(subject).to receive(:set_morphosource_permissions)
        post :create, params: collection_params.merge(collection_type_gid: project_collection_type.gid)
      end
    end
  end

  describe '#set_default_permissions' do
    let(:collection)  { FactoryBot.create(:project, depositor: user.ms_id) }
    let(:parent)      { FactoryBot.create(:team) }
    let(:role)        { Role.new(name: 'role') }

    before do
      subject.instance_variable_set(:@collection, collection)
      allow(Role).to receive(:find_by).and_return(role)
    end

    it 'calls #create_collection_groups' do
      expect(collection).to receive(:create_collection_groups)
      subject.set_default_permissions
    end

    it 'creates a custom permission template' do
      expect(Morphosource::Collections::PermissionsCreateService).to receive(:create_default).with(collection: collection)
      subject.set_default_permissions
    end

    context 'collection type assigns groups' do
      context 'collection is a team' do
        it 'calls #set_default_permissions and #set_morphosource_permissions' do
          expect(subject).to receive(:set_default_permissions).and_call_original
          expect(subject).to receive(:set_morphosource_permissions)
          post :create, params: collection_params.merge(collection_type_gid: team_collection_type.gid)
        end
      end

      context 'collection is a project' do
        it 'calls #set_default_permissions and #set_morphosource_permissions' do
          expect(subject).to receive(:set_default_permissions).and_call_original
          expect(subject).to receive(:set_morphosource_permissions)
          post :create, params: collection_params.merge(collection_type_gid: project_collection_type.gid)
        end
      end
    end

    context 'the collection does not have a parent' do

      before do
        allow(subject).to receive(:params).and_return({})
      end

      it 'does not call #copy_parent_membership' do
        expect(collection).not_to receive(:copy_parent_membership)
        subject.set_default_permissions
      end
    end

    context 'the collection has a parent' do

      before do
        allow(subject).to receive(:params).and_return({ parent_id: parent.id })
        allow(Collection).to receive(:find).with(parent.id).and_return(parent)
      end

      it 'calls #copy_parent_membership' do
        expect(collection).to receive(:create_collection_groups)
        subject.set_default_permissions
      end
    end
  end
end
