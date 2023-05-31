require 'rails_helper'
require 'spec_helper'

RSpec.describe Morphosource::Collections::MediaLists::SequentialSectionListsController, type: :controller do

  let(:user)                                    { User.create(email: 'user@email.com', password: 'password') }
  let(:depositor)                               { User.create(email: 'depositor@email.com', password: 'password') }
  let(:sequential_section_list)                 { FactoryBot.create(:sequential_section_list, title: ['sequential Section list'], depositor: depositor.ms_id) }
  let(:media)                                   { Media.create(title: ['media'], depositor: depositor.ms_id, visibility: 'open') }

  describe 'temporary admin-only restriction' do
    let(:params)  { { id: sequential_section_list.id } }
    before do
      Morphosource::Collections::PermissionsCreateService.create_default(collection: sequential_section_list)
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
        get :show, params: params
        expect(response.status).to eq(200)
        get :about, params: params
        expect(response.status).to eq(200)
        get :media_export_with_intersections_facet, format: :csv, params: params
        expect(response.status).to eq(200)
        get :media_download_counts_with_intersections_facet, format: :csv, params: params
        expect(response.status).to eq(200)
        get :preview, params: params.merge( { media_id: media.id } )
        expect(response.status).to eq(200)
      end
    end

    context 'user is not an admin' do
      it 'responds with a 200' do
        get :show, params: params
        expect(response.status).to eq(200)
        get :about, params: params
        expect(response.status).to eq(200)
        get :preview, params: params.merge( { media_id: media.id } )
        expect(response.status).to eq(200)
      end

      it 'redirects to root' do
        get :media_export_with_intersections_facet, params: params
        expect(response.status).to eq(302)
        get :media_download_counts_with_intersections_facet, params: params
        expect(response.status).to eq(302)
      end
    end
  end

  describe 'presenter_class' do
    it {expect(subject.presenter_class).to eq(Morphosource::Collections::MediaLists::SequentialSectionListPresenter) }
  end

  describe 'search_action_url' do
    before do
      subject.instance_variable_set(:@curation_concern, sequential_section_list)
    end
    it 'is sequential_section_list_path' do
      expect(subject.send(:search_action_url)).to eq("/sequential_section_lists/#{sequential_section_list.id}?locale=en")
    end
  end

  describe 'search_facet_path' do
    let(:facet_id)  { 'depositor_ssi' }
    before do
      subject.instance_variable_set(:@collection, sequential_section_list)
    end
    it 'is sequential_section_list_path' do
      expect(subject.send(:search_facet_path, {id: facet_id})).to eq("/sequential_section_lists/#{sequential_section_list.id}/facet/#{facet_id}?locale=en")
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

    it { expect(subject.search_action_for_dashboard).to eq(main_app.sequential_section_list_path(id: collection.id, locale: 'en')) }
  end
end
