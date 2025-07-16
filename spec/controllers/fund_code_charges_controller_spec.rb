require 'rails_helper'
include ActionDispatch::TestProcess

RSpec.describe Morphosource::Admin::FundCodeChargesController, :type => :controller do
  describe 'GET #index' do
    let(:user) { FactoryBot.create(:user) }
    let(:admin) { FactoryBot.create(:admin) } 
    let(:api_user) { FactoryBot.create(:user) }


    context 'when non-admin user is logged in' do
      before do 
        allow(controller).to receive(:current_user) { user }
      end

      context 'user is not authorized to read admin dashboard' do
        it 'page is redirected to root' do
          get :index
          expect(response).to redirect_to('/?locale=en')
        end
      end
    end

    context 'when admin user is logged in' do
      before do 
        allow(controller).to receive(:current_user) { admin }
      end

      context 'user is authorized to read admin dashboard' do
        it 'page is returned successfully' do
          get :index
          expect(response.code).to eq("200")
        end
      end
    end

    context 'when no user is logged in' do
      it 'page is redirected to root' do
        get :index
        expect(response).to redirect_to('/?locale=en')
      end

      context 'request is JSON format and user provides no API token' do
        it 'returns 401 unauthorized' do
          get :index, :format => :json
          expect(response.content_type).to include('application/json')
          expect(response.code).to eq("401")
        end 
      end

      context 'request is JSON format and user provides invalid API token' do
        it 'returns 404 not found' do
          controller.request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('', "nonsense")
          get :index, :format => :json
          expect(response.content_type).to include('application/json')
          expect(response.code).to eq("404")
        end 
      end

      context 'request is JSON format and user provides valid API token' do
        before do
          Role.find_or_create_by(name: 'charge_api')
          api_user.make_charge_api_user
          api_user.save!
        end
      
        it 'returns fund code charge information successfully' do
          controller.request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('', api_user.token)
          get :index, :format => :json
          expect(response.content_type).to include('application/json')
          expect(response.code).to eq("200")
          expect(JSON.parse(response.body)).to be_an_instance_of(Array)
        end 
      end
    end
  end
end