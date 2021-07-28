require 'rails_helper'
include ActionDispatch::TestProcess

RSpec.describe Morphosource::Admin::FundCodeChargesController, :type => :controller do
  describe 'GET #index' do
    let(:user) { User.create(email: 'user@email.com', password: 'password')}

    before do 
      allow(controller).to receive(:current_user) { user }
    end

    context 'when user is not authorized to read admin dashboard or does not have API key' do
      it 'page is redirected to root' do
        get :index
        expect(response).to redirect_to('/?locale=en')
      end 

      it 'fund code JSON route is forbidden' do
        get :index, :format => :json
        expect(response.content_type).to eq('application/json')
        expect(JSON.parse(response.body)['code']).to eq(401)
      end 
    end

    context 'when a user is authorized' do
      before do 
        Role.find_or_create_by(name: 'charge_api')
        user.make_charge_api_user
        user.save!
      end

      it 'fund codes are accessible' do 
        controller.request.headers['HTTP_X_API_KEY'] = user.token 
        get :index, :format => :json
        expect(response.content_type).to eq('application/json')
        expect(JSON.parse(response.body)).to be_an_instance_of(Array)
      end
    end
  end
end