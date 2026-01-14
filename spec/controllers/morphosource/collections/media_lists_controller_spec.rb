require 'rails_helper'
require 'spec_helper'

RSpec.describe Morphosource::Collections::MediaListsController, type: :controller do

  let(:depositor) { User.create(email: 'depositor@email.com', password: 'password') }
  let(:list)      { FactoryBot.create(:media_list, title: ['media list'], depositor: depositor.ms_id, visibility: 'open') }

  describe 'restricted actions' do
    let(:params)  { { id: list.id } }

    before do
      Morphosource::Collections::PermissionsCreateService.create_default(collection: list)
      sign_in user
    end

    context 'user is an admin' do
      let(:user) { FactoryBot.create(:admin) }

      it 'allows access to about' do
        get :about, params: params
        expect(response.status).to eq(200)
      end

      it 'allows access to facet' do
        get :facet, params: { collection_id: list.id, id: 'media_type' }
        expect(response.status).to eq(200)
      end

      it 'allows access to media_download_counts_with_intersections_facet' do
        get :media_download_counts_with_intersections_facet, params: params, format: :csv
        expect(response.status).to eq(200)
      end

      it 'allows access to media_downloads' do
        get :media_downloads, params: params, format: :csv
        expect(response.status).to eq(200)
      end

      it 'allows access to media_export_with_intersections_facet' do
        get :media_export_with_intersections_facet, params: params, format: :csv
        expect(response.status).to eq(200)
      end

      it 'allows access to media_requests' do
        get :media_requests, params: params, format: :csv
        expect(response.status).to eq(200)
      end

      it 'allows access to show' do
        get :show, params: params
        expect(response.status).to eq(200)
      end
    end

    context 'user is a list manager' do
      let(:user) { depositor }

      context 'allows some actions and denies others' do
        # allow
        it 'allows access to about' do
          get :about, params: params
          expect(response.status).to eq(200)
        end


        it 'allows access to facet' do
          get :facet, params: { collection_id: list.id, id: 'media_type' }
          expect(response.status).to eq(200)
        end

        it 'allows access to media_download_counts_with_intersections_facet' do
          get :media_download_counts_with_intersections_facet, params: params, format: :csv
          expect(response.status).to eq(200)
        end

        it 'allows access to media_export_with_intersections_facet' do
          get :media_export_with_intersections_facet, params: params, format: :csv
          expect(response.status).to eq(200)
        end

        it 'allows access to show' do
          get :show, params: params
          expect(response.status).to eq(200)
        end

        # deny
        it 'denies access to media_downloads' do
          get :media_downloads, params: params, format: :csv
          expect(response.status).to eq(403)
        end

        it 'denies access to media_requests' do
          get :media_requests, params: params, format: :csv
          expect(response.status).to eq(403)
        end
      end
    end

    context 'user is not an admin or list manager' do
      let(:user)  { FactoryBot.create(:registered_user) }

      it 'allows some actions and denies others' do
        # allow
        get :about, params: params
        expect(response.status).to eq(200)
        controller.instance_variable_set(:@presenter, nil)
        get :facet, params: { collection_id: list.id, id: 'media_type' }
        expect(response.status).to eq(200)
        controller.instance_variable_set(:@presenter, nil)
        get :show, params: params
        expect(response.status).to eq(200)
        controller.instance_variable_set(:@presenter, nil)
        # deny
        get :media_download_counts_with_intersections_facet, params: params, format: :csv
        expect(response.status).to eq(403)
        controller.instance_variable_set(:@presenter, nil)
        get :media_downloads, params: params, format: :csv
        expect(response.status).to eq(403)
        controller.instance_variable_set(:@presenter, nil)
        get :media_export_with_intersections_facet, params: params, format: :csv
        expect(response.status).to eq(403)
        controller.instance_variable_set(:@presenter, nil)
        get :media_requests, params: params, format: :csv
        expect(response.status).to eq(403)
      end
    end
  end

  describe 'presenter_class' do
    it {expect(subject.presenter_class).to eq(Morphosource::Collections::MediaListPresenter) }
  end

  describe 'search_action_url' do
    before do
      subject.instance_variable_set(:@collection, list)
    end
    it 'is media_list_path' do
      expect(subject.send(:search_action_url)).to eq(media_list_path(list.id))
    end
  end

  describe 'search_facet_path' do
    let(:facet_id)  { 'depositor_ssi' }
    before do
      subject.instance_variable_set(:@collection, list)
    end
    it 'is media_list_media_facet_path' do
      expect(subject.send(:search_facet_path, {id: facet_id})).to eq(media_list_media_facet_path(list.id, id: facet_id))
    end
  end

  # helpers/morphosource/my/works_helper
  describe '#search_action_for_dashboard' do
    let(:main_app)    { Rails.application.routes.url_helpers }
    let(:params)      { { controller: controller.controller_path } }
    let(:collection)  { double('collection', id: 'abc')}
    subject           { controller.view_context }

    before do
      allow(subject).to receive(:params).and_return(params)
      subject.instance_variable_set(:@collection, collection)
    end

    it { expect(subject.search_action_for_dashboard).to eq(main_app.media_list_path(id: collection.id, locale: 'en')) }
  end
end
