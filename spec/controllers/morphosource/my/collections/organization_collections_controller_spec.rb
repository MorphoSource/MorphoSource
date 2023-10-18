require 'rails_helper'

RSpec.describe Morphosource::My::Collections::OrganizationCollectionsController, type: :controller do

  describe 'temporary admin-only restriction' do
    before do
      sign_in user
    end

    context 'user is an admin' do
      let(:user)  { FactoryBot.create(:admin) }

      it 'responds with a 200' do
        get :index
        expect(response.status).to eq(200)
      end
    end

    context 'user is not an admin' do
      let(:user)  { FactoryBot.create(:contributor) }

      it 'responds with a redirect' do
        get :index
        expect(response.status).to eq(302)
      end
    end
  end

  describe 'collections_type' do
    it { expect(subject.collections_type).to eq('organizations') }
  end

  describe 'search_builder_class' do
    it { expect(subject.search_builder_class).to be(Morphosource::My::Collections::OrganizationsSearchBuilder) }
  end

  describe 'search_action_url' do
    it 'is media_list_path' do
      expect(subject.search_action_url).to include("/dashboard/my/organizations?locale=en")
    end
  end

  describe 'search_action_for_dashboard' do
    it { expect(subject.search_action_for_dashboard).to eq("/dashboard/my/organizations?locale=en") }
  end
end
