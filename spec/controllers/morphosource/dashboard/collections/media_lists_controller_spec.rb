# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Morphosource::Dashboard::Collections::MediaListsController, type: :controller do

  let(:user)                        { User.create(email: 'user@email.com', password: 'password') }
  let(:depositor)                   { User.create(email: 'depositor@email.com', password: 'password') }
  let(:media_list)                  { MediaList.create(title: ['media list'], collection_type_gid: media_list_collection_type.gid, depositor: depositor.ms_id) }

  describe 'temporary admin-only restriction' do
    let(:params)  { { id: media_list.id } }
    before do
      media_list.visibility = 'open'
      media_list.save!
      sign_in user
    end

    context 'user is an admin' do
      let(:admin_role)  { Role.create(name: 'admin') }
      before do
        admin_role.users << user
        admin_role.save
      end
      it 'responds with a 200' do
        get :edit, params: params
        expect(response.status).to eq(200)
        get :members, params: params
        expect(response.status).to eq(200)
        get :new
        expect(response.status).to eq(200)
        post :create, params: { "media_list" => { "title" => ['media list'], "collection_type_gid" => media_list_collection_type.gid } }
        expect(response.status).to eq(200)
        put :update, params: { "media_list" => { "id" => media_list.id } }
        expect(response.status).to eq(200)
        patch :update, params: { "media_list" => { "id" => media_list.id } }
        expect(response.status).to eq(200)
        get :files, params: params
        expect(response.status).to eq(200)
      end
    end

    context 'user is not an admin' do
      it 'responds with a redirect' do
      get :edit, params: params
        expect(response.status).to eq(302)
        get :members, params: params
        expect(response.status).to eq(302)
        get :new
        expect(response.status).to eq(302)
        post :create, params: { "media_list" => { "title" => ['media list'], "collection_type_gid" => media_list_collection_type.gid } }
        expect(response.status).to eq(302)
        put :update, params: { "media_list" => { "id" => media_list.id } }
        expect(response.status).to eq(302)
        patch :update, params: { "media_list" => { "id" => media_list.id } }
        expect(response.status).to eq(302)
        get :files, params: params
        expect(response.status).to eq(302)
      end
    end
  end

  describe 'presenter_class' do
    it { expect(controller.presenter_class).to be(Morphosource::Collections::MediaListPresenter) }
  end

  describe 'default_collection_type' do
    let!(:media_list_collection_type)  { Hyrax::CollectionType.create(title: 'Media List') }

    it { expect(subject.send(:default_collection_type).title).to eq("Media List") }
  end

  describe 'collection_class' do
    it { expect(subject.send(:collection_class)).to eq(MediaList) }
  end
end
