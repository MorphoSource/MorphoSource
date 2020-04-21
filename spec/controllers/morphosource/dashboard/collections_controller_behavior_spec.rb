# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Dashboard::CollectionsControllerBehavior do
  routes { Hyrax::Engine.routes }

  let(:user)                    { User.create(email: 'email@email.com', password: 'password') }
  let(:team_collection_type)    { Hyrax::CollectionType.create(title: 'Team') }
  let(:project_collection_type) { Hyrax::CollectionType.create(title: 'Project') }
  let(:another_collection_type) { Hyrax::CollectionType.create(title: 'Another') }
  let(:collection_attrs)        { { title: ['New Collection'] } }

  before do
    sign_in user
    @controller = Hyrax::Dashboard::CollectionsController.new
  end

  describe '#set_default_permissions' do
    context 'collection type does not assign groups' do
      it 'calls #set_default_permissions and does not call #set_morphosource_permissions' do
        expect(subject).to receive(:set_default_permissions).and_call_original
        expect(subject).not_to receive(:set_morphosource_permissions)
        post :create, params: { collection: collection_attrs, collection_type_gid: another_collection_type.gid }
      end
    end
    context 'collection type assigns groups' do
      context 'collection is a team' do
        it 'calls #set_default_permissions and #set_morphosource_permissions' do
          expect(subject).to receive(:set_default_permissions).and_call_original
          expect(subject).to receive(:set_morphosource_permissions)
          post :create, params: { collection: collection_attrs, collection_type_gid: team_collection_type.gid }
        end
      end
      context 'collection is a project' do
        it 'calls #set_default_permissions and #set_morphosource_permissions' do
          expect(subject).to receive(:set_default_permissions).and_call_original
          expect(subject).to receive(:set_morphosource_permissions)
          post :create, params: { collection: collection_attrs, collection_type_gid: project_collection_type.gid }
        end
      end
    end
  end
end
