require 'rails_helper'
include ActionDispatch::TestProcess

RSpec.describe RemoteFileSubmittersController, :type => :controller do

  include Rails.application.routes.url_helpers

  let(:user)          { User.create(email: 'user@email.com', password: 'password') }
  let!(:remote_file_submitters)  { Role.create(name: 'remote_file_submitter') }
  let(:admins)        { Role.create(name: 'admin') }
  let(:admin)         { User.create(email: 'admin@email.com', password: 'password') }
  let(:params)        { { id: user.ms_id } }

  describe '#make_remote_file_submitter' do
    context 'current user is not an admin' do
      before do
        sign_in user
      end

      it 'returns a 204' do
        post :make_remote_file_submitter, params: params
        expect(user.remote_file_submitter?).to be(false)
        expect(response.status).to eq(204)
      end
    end

    context 'current user is an admin' do
      before do
        admins.users << admin
        admins.save
        sign_in admin
      end

      it 'makes the user a remote_file_submitter' do
        post :make_remote_file_submitter, params: params
        expect(user.remote_file_submitter?).to be(true)
        expect(response).to redirect_to("http://test.host/users/#{user.ms_id}?locale=en")
      end
    end
  end

  describe '#remove_remote_file_submitter' do
    context 'current user is not an admin' do
      before do
        sign_in user
      end

      it 'returns a 204' do
        post :remove_remote_file_submitter, params: params
        expect(response.status).to eq(204)
      end
    end

    context 'current user is an admin' do
      before do
        remote_file_submitters.users << user
        remote_file_submitters.save
        admins.users << admin
        admins.save
        sign_in admin
      end

      it 'removes the user as a remote_file_submitter' do
        post :remove_remote_file_submitter, params: params
        expect(user.remote_file_submitter?).to be(false)
        expect(response).to redirect_to("http://test.host/users/#{user.ms_id}?locale=en")
      end
    end
  end
end
