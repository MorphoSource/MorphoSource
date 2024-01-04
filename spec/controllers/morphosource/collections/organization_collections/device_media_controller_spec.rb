require 'rails_helper'
require 'spec_helper'

RSpec.describe Morphosource::Collections::OrganizationCollections::DeviceMediaController, type: :controller do
  let(:depositor)     { User.create(email: 'depositor@email.com', password: 'password') }
  let!(:organization) { FactoryBot.create(:organization_collection, visibility: 'open', depositor: depositor.ms_id) }

  describe 'collection access' do
    before do
      sign_in user
      organization.create_collection_groups
      Morphosource::Collections::PermissionsCreateService.create_default(collection: organization)
    end

    # TODO: Remove admin-only restriction tests when organization collections go live on production
    describe 'temporary admin-only restriction' do
      let(:params)  { { id: organization.id } }

      context 'user is an admin' do
        let(:user) { FactoryBot.create(:admin) }

        it 'responds with a 200' do
          get :show, params: params
          expect(response.status).to eq(200)
          get :media_export_with_intersections_facet, params: params, format: :csv
          expect(response.status).to eq(200)
          get :media_download_counts_with_intersections_facet, params: params, format: :csv
          expect(response.status).to eq(200)
          get :media_downloads, params: params, format: :csv
          expect(response.status).to eq(200)
          get :media_requests, params: params, format: :csv
          expect(response.status).to eq(200)
        end
      end

      context 'user is not an admin' do
        let(:user)  { FactoryBot.create(:registered_user) }

        it 'redirects to root' do
          get :show, params: params
          expect(response.status).to eq(302)
          get :media_export_with_intersections_facet, params: params
          expect(response.status).to eq(302)
          get :media_download_counts_with_intersections_facet, params: params
          expect(response.status).to eq(302)
          get :media_downloads, params: params, format: :csv
          expect(response.status).to eq(302)
          get :media_requests, params: params, format: :csv
          expect(response.status).to eq(302)
        end
      end
    end

    describe 'collection access' do
      let(:params)  { { id: organization.id } }

      before do
        allow(controller).to receive(:authorize_admin).and_return(true)
      end

      context 'user is an admin' do
        let(:user) { FactoryBot.create(:admin) }

        it 'responds with a 200' do
          get :show, params: params
          expect(response.status).to eq(200)
          get :media_export_with_intersections_facet, params: params, format: :csv
          expect(response.status).to eq(200)
          get :media_download_counts_with_intersections_facet, params: params, format: :csv
          expect(response.status).to eq(200)
          get :media_downloads, params: params, format: :csv
          expect(response.status).to eq(200)
          get :media_requests, params: params, format: :csv
          expect(response.status).to eq(200)
        end
      end

      context 'user is not an admin' do
        let(:user)  { FactoryBot.create(:contributor) }

        it 'responds with a 200' do
          get :show, params: params
          expect(response.status).to eq(200)
        end

        context 'user is a collection editor' do
          let(:user)  { depositor }

          it 'responds with a 200' do
            get :media_export_with_intersections_facet, params: params, format: :csv
            expect(response.status).to eq(200)
            get :media_download_counts_with_intersections_facet, params: params, format: :csv
            expect(response.status).to eq(200)
            get :media_downloads, params: params, format: :csv
            expect(response.status).to eq(200)
            get :media_requests, params: params, format: :csv
            expect(response.status).to eq(200)
          end
        end

        context 'user is not a collection editor' do
          let(:user)  { FactoryBot.create(:contributor) }

          it 'responds with a 403' do
            get :media_export_with_intersections_facet, params: params
            expect(response.status).to eq(403)
            get :media_download_counts_with_intersections_facet, params: params
            expect(response.status).to eq(403)
            get :media_downloads, params: params, format: :csv
            expect(response.status).to eq(403)
            get :media_requests, params: params, format: :csv
            expect(response.status).to eq(403)
          end
        end
      end
    end
  end

  describe 'search_builder_class' do
    it { expect(subject.search_builder_class).to eq(Morphosource::Collections::OrganizationCollections::DeviceMediaSearchBuilder) }
  end

  describe 'presenter_class' do
    it { expect(subject.presenter_class).to eq(Morphosource::Collections::OrganizationPresenter) }
  end

  describe 'search_action_url' do
    let(:user) { FactoryBot.create(:admin) }

    before do
      subject.instance_variable_set(:@curation_concern, organization)
    end
    it 'is organization_device_media_path' do
      expect(subject.send(:search_action_url)).to eq("/organizations/#{organization.id}/device-media?locale=en")
    end
  end

  describe 'search_facet_path' do
    let(:user) { FactoryBot.create(:admin) }

    let(:facet_id)  { 'depositor_ssim' }
    before do
      subject.instance_variable_set(:@collection, organization)
    end
    it 'is device_media_facet_path' do
      expect(subject.send(:search_facet_path, {id: facet_id})).to eq("/organizations/#{organization.id}/device-media/facet/#{facet_id}?locale=en")
    end
  end

  describe 'tab' do
    it {expect(subject.send(:tab)).to eq(:device_media) }
  end
end