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
        expect(response).not_to redirect_to(edit_profile_type_path)
      end
    end

    context 'when profile_type is not present AND user has not selected a profile_type' do
      it 'should redirect to edit_profile_type_path' do
        post :create, params: { user: { email: user2.email, password: user2.password } }
        expect(response).to redirect_to(edit_profile_type_path)
      end
    end

    context 'when profile_type is not present AND user has selected a profile_type' do
      it 'should save profile_type info, and not redirect to edit_profile_type_path' do
        post :create, params: { user: { email: user2.email, password: user2.password, profile_type: 'Artist', demographics: ['Artist'] } }
        expect(response).not_to redirect_to(edit_profile_type_path)
        user2.reload
        expect(user2.profile_type).to eq('Artist')
        expect(user2.demographics).to eq(['Artist'])
      end
    end
  end

end
