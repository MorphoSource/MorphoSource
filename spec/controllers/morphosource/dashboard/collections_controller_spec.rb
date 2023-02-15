# frozen_string_literal: true
require 'rails_helper'
require 'morphosource/dashboard/collections_controller'
require 'hyrax/dashboard/collections_controller'
require 'hyrax/forms/collection_form'

RSpec.describe Morphosource::Dashboard::CollectionsController, type: :controller do

  let(:user)  { User.create(email: 'email@email.com', password: 'password')}
  let!(:contributors)  { Role.create(name: 'contributor') }

  let(:team_collection_type) { Hyrax::CollectionType.create(title: 'Team', machine_id: 'team') }
  let(:project_collection_type) { Hyrax::CollectionType.create(title: 'Project', machine_id: 'project') }
  let(:another_collection_type) { Hyrax::CollectionType.create(title: 'Another') }
  let(:collection_params) { { collection: { title: 'New Collection' } } }

  before do
    contributors.users += [user]
    allow(user).to receive(:can?).with(:create_any, Collection).and_return(true)
    sign_in user
    allow(subject).to receive(:current_user).and_return(user)
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
    let(:collection) { Collection.create(title: ['New Collection'], collection_type_gid: project_collection_type.gid, depositor: user.ms_id) }
    let(:parent) { Collection.create(title: ['Parent Collection'], collection_type_gid: team_collection_type.gid) }
    let(:role) { Role.new(name: 'role') }
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
