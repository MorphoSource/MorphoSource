require 'rails_helper'
require 'spec_helper'

RSpec.describe Morphosource::Collections::OrganizationCollections::PhysicalObjects::BiologicalSpecimensController, type: :controller do

  let(:main_app)      { Rails.application.routes.url_helpers }
  let(:depositor)     { User.create(email: 'depositor@email.com', password: 'password') }
  let!(:organization) { FactoryBot.create(:organization_collection, visibility: 'open', depositor: depositor.ms_id) }

  describe 'OrganizationCollectionsControllerBehavior' do
    it 'is included' do
      expect(described_class.ancestors).to include(Morphosource::Collections::OrganizationCollectionsControllerBehavior)
    end
  end

  describe 'collection access' do
    before do
      sign_in user
      Morphosource::Collections::PermissionsCreateService.create_default(collection: organization)
    end

    describe 'collection access' do
      let(:params)  { { id: organization.id } }

      context 'user is an admin' do
        let(:user) { FactoryBot.create(:admin) }

        it 'responds with a 200' do
          get :show, params: params
          expect(response.status).to eq(200)
          get :objects_export, params: params, format: :csv
          expect(response.status).to eq(200)
        end
      end

      context 'user is not an admin' do
        let(:user)  { FactoryBot.create(:contributor) }

        it 'responds with a 200' do
          get :show, params: params
          expect(response.status).to eq(200)
        end

        context 'user is a collection manager' do
          let(:user)  { depositor }

          before do
            organization.managers << user
            organization.managers_group.save
          end

          it 'responds with a 200' do
            get :objects_export, params: params, format: :csv
          expect(response.status).to eq(200)
          end
        end

        context 'user is not a collection manager' do
          let(:user)  { FactoryBot.create(:contributor) }

          it 'responds with a 403' do
            get :objects_export, params: params, format: :csv
          expect(response.status).to eq(403)
          end
        end
      end
    end
  end

  describe 'media_count_search_builder_class' do
    it {expect(subject.media_count_search_builder_class).to eq(Morphosource::Collections::OrganizationCollections::OrganizationMediaSearchBuilder) }
  end

  describe 'presenter_class' do
    it {expect(subject.presenter_class).to eq(Morphosource::Collections::OrganizationPresenter) }
  end

  describe '#search_action_for_dashboard' do
    before do
      subject.instance_variable_set(:@collection, organization)
    end

    it { expect(subject.search_action_for_dashboard).to eq(main_app.organization_specimens_path(organization, locale: 'en')) }
  end
end