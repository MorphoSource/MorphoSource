# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::Dashboard::CollectionsController, type: :controller do
  routes { Hyrax::Engine.routes }

  let(:user) { User.create(email: 'email@email.com', password: 'password') }
  let(:team_collection_type) { Hyrax::CollectionType.create(title: 'Team', machine_id: 'team') }
  let(:project_collection_type) { Hyrax::CollectionType.create(title: 'Project', machine_id: 'project') }
  let(:collection_params) { { collection: { title: ['New Collection'] } } }

  before do
    sign_in user
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

    context 'The collection is not a team or project' do
      it 'does not call set_morphosource_permissions' do
        expect(subject).not_to receive(:set_morphosource_permissions)
        post :create, params: collection_params
      end
    end
  end

  describe '#set_morphosource_permissions' do
    let(:collection) { Collection.create(title: ['New Collection'], collection_type_gid: project_collection_type.gid, depositor: user.ms_id) }
    let(:parent) { Collection.create(title: ['Parent Collection'], collection_type_gid: team_collection_type.gid) }
    let(:role) { Role.new(name: 'role') }
    before do
      subject.instance_variable_set(:@collection, collection)
      allow(Role).to receive(:find_by).and_return(role)
    end
    it 'calls #create_collection_groups' do
      expect(collection).to receive(:create_collection_groups)
      subject.set_morphosource_permissions
    end
    it 'creates a custom permission template' do
      expect(Morphosource::Collections::PermissionsCreateService).to receive(:create_default).with(collection: collection)
      subject.set_morphosource_permissions
    end
    context 'the collection does not have a parent' do
      before do
        allow(subject).to receive(:params).and_return({})
      end
      it 'does not call #copy_parent_membership' do
        expect(collection).not_to receive(:copy_parent_membership)
        subject.set_morphosource_permissions
      end
    end
    context 'the collection has a parent' do
      before do
        allow(subject).to receive(:params).and_return({ parent_id: parent.id })
        allow(Collection).to receive(:find).with(parent.id).and_return(parent)
      end
      it 'calls #copy_parent_membership' do
        expect(collection).to receive(:create_collection_groups)
        subject.set_morphosource_permissions
      end
    end
  end
end
