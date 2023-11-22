require 'rails_helper'
require 'spec_helper'

RSpec.describe Morphosource::Collections::OrganizationCollectionsController, type: :controller do
  let(:depositor)     { FactoryBot.create(:contributor) }
  let!(:organization) { FactoryBot.create(:organization_collection, visibility: 'open', depositor: depositor.ms_id) }

  describe 'temporary admin-only restriction' do
    let(:params)  { { id: organization.id } }

    before do
      sign_in user
    end

    context 'user is an admin' do
      let(:user) { FactoryBot.create(:admin) }

      it 'responds with a 200' do
        get :show, params: params
        expect(response.status).to eq(200)
        get :about, params: params
        expect(response.status).to eq(200)
        get :media_export_with_intersections_facet, params: params, format: :csv
        expect(response.status).to eq(200)
        get :media_download_counts_with_intersections_facet, params: params, format: :csv
        expect(response.status).to eq(200)
      end
    end

    context 'user is not an admin' do
      let(:user)  { FactoryBot.create(:registered_user) }

      it 'redirects to root' do
        get :show, params: params
        expect(response.status).to eq(302)
        get :about, params: params
        expect(response.status).to eq(302)
        get :media_export_with_intersections_facet, params: params
        expect(response.status).to eq(302)
        get :media_download_counts_with_intersections_facet, params: params
        expect(response.status).to eq(302)
      end
    end
  end

  describe 'presenter_class' do
    it {expect(subject.presenter_class).to eq(Morphosource::Collections::OrganizationPresenter) }
  end

  describe 'search_action_url' do
    let(:user) { FactoryBot.create(:admin) }

    before do
      subject.instance_variable_set(:@curation_concern, organization)
    end
    it 'is media_list_path' do
      expect(subject.send(:search_action_url)).to eq("/organizations/#{organization.id}?locale=en")
    end
  end

  describe 'search_facet_path' do
    let(:user) { FactoryBot.create(:admin) }

    let(:facet_id)  { 'depositor_ssim' }
    before do
      subject.instance_variable_set(:@collection, organization)
    end
    it 'is media_list_path' do
      expect(subject.send(:search_facet_path, {id: facet_id})).to eq("/organizations/#{organization.id}/facet/#{facet_id}?locale=en")
    end
  end

  describe 'collection_type' do
    it {expect(subject.collection_type).to eq(Hyrax::CollectionType.find_by(Morphosource::CollectionTypes::Organizations::SETTINGS)) }
  end
end