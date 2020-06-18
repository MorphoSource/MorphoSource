require 'rails_helper'
require 'digest'

include ActionDispatch::TestProcess

RSpec.describe SessionsController, :type => :controller  do

  let(:user)          { User.create(email: "example@email.com", password: "password") }
  let(:ms1_user)      { User.create(email: "test@test.com", password: "password", ms1_user: true, ms1_password_hash: Digest::MD5.hexdigest('hash')) }


  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe 'new' do
    it 'migrated ms1 user gets redirected' do
      post 'new', :params => { user: { email: ms1_user.email, password: 'hash' } } 
      expect(response).to have_http_status(:redirect)
    end

    it 'new (non-ms1) user gets successful response' do
      post 'new', :params => { user: { email: user.email, password: user.password } } 
      expect(response).to have_http_status(:success)
    end
  end
end
