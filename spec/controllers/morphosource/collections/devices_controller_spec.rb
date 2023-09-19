require 'rails_helper'
require 'spec_helper'

RSpec.describe Morphosource::Collections::DevicesController, type: :controller do
  let(:depositor)     { FactoryBot.create(:contributor) }
  let(:organization)  { FactoryBot.create(:organization_collection, visibility: 'open', depositor: depositor.ms_id) }

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
      end
    end

    context 'user is not an admin' do
      let(:user)  { FactoryBot.create(:registered_user) }

      it 'redirects to root' do
        get :show, params: params
        expect(response.status).to eq(302)
      end
    end
  end
end