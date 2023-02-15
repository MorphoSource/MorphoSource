# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Morphosource::Dashboard::Collections::MediaLists::SequentialSectionListsController, type: :controller do
  include SingleValuedForm

  let(:user)                                    { User.create(email: 'user@email.com', password: 'password') }
  let(:depositor)                               { User.create(email: 'depositor@email.com', password: 'password') }
  let(:sequential_section_list_collection_type) { Hyrax::CollectionType.create(title: 'Sequential Section List') }
  let(:sequential_section_list)                 { SequentialSectionList.create(title: ['sequential section list'], collection_type_gid: sequential_section_list_collection_type.gid, depositor: depositor.ms_id) }

  describe 'temporary admin-only restriction' do
    let(:params)  { { id: sequential_section_list.id } }
    before do
      sequential_section_list.visibility = 'open'
      sequential_section_list.save!
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
        post :create, params: { "sequential_section_list" => { "title" => ['sequential section list'], "collection_type_gid" => sequential_section_list_collection_type.gid } }
        expect(response.status).to eq(200)
        put :update, params: { "sequential_section_list" => { "id" => sequential_section_list.id } }
        expect(response.status).to eq(200)
        patch :update, params: { "sequential_section_list" => { "id" => sequential_section_list.id } }
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
        post :create, params: { "sequential_section_list" => { "title" => ['sequential section list'], "collection_type_gid" => sequential_section_list_collection_type.gid } }
        expect(response.status).to eq(302)
        put :update, params: { "sequential_section_list" => { "id" => sequential_section_list.id } }
        expect(response.status).to eq(302)
        patch :update, params: { "sequential_section_list" => { "id" => sequential_section_list.id } }
        expect(response.status).to eq(302)
        get :files, params: params
        expect(response.status).to eq(302)
      end
    end
  end


  describe 'presenter_class' do
    it { expect(controller.presenter_class).to be(Morphosource::Collections::MediaLists::SequentialSectionListPresenter) }
  end

  describe 'default_collection_type' do
    let!(:sequential_section_list_collection_type)  { Hyrax::CollectionType.create(title: 'Sequential Section List') }

    it { expect(subject.send(:default_collection_type).title).to eq("Sequential Section List") }
  end

  describe 'collection_class' do
    it { expect(subject.send(:collection_class)).to eq(SequentialSectionList) }
  end
end
