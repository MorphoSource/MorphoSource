require 'rails_helper'
require 'digest'

include ActionDispatch::TestProcess

RSpec.describe SessionsController, :type => :controller  do

  let(:user)          { User.create(email: "example@email.com", password: "password", profile_type: "test") }
  let(:user2)          { User.create(email: "user2@email.com", password: "password2", profile_type: nil) }
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

  describe 'POST #create' do
    context 'when profile_type is present' do
      it 'should not redirect to edit_profile_type_path' do
        post :create, params: { user: { email: user.email, password: user.password } }
        expect(response).not_to redirect_to(edit_profile_type_path user.id)
      end
    end
    context 'when profile_type is not present' do
      it 'should redirect to edit_profile_type_path' do
        post :create, params: { user: { email: user2.email, password: user2.password } }
        expect(response.redirect_url).to include(edit_profile_type_path(user2.ms_id))
      end
    end
  end

end
