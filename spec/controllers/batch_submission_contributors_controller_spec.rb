require 'rails_helper'
include ActionDispatch::TestProcess

RSpec.describe BatchSubmissionContributorsController, :type => :controller do

  include Rails.application.routes.url_helpers

  let(:user)          { User.create(email: 'user@email.com', password: 'password') }
  let!(:batch_submission_contributors)  { Role.create(name: 'batch_submission_contributor') }
  let(:admins)        { Role.create(name: 'admin') }
  let(:admin)         { User.create(email: 'admin@email.com', password: 'password') }
  let(:params)        { { id: user.ms_id } }

  describe '#make_batch_submission_contributor' do
    context 'current user is not an admin' do
      before do
        sign_in user
      end

      it 'returns a 204' do
        post :make_batch_submission_contributor, params: params
        expect(user.batch_submission_contributor?).to be(false)
        expect(response.status).to eq(204)
      end
    end

    context 'current user is an admin' do
      before do
        admins.users << admin
        admins.save
        sign_in admin
      end

      it 'makes the user a batch_submission_contributor' do
        post :make_batch_submission_contributor, params: params
        expect(user.batch_submission_contributor?).to be(true)
        expect(response).to redirect_to("http://test.host/users/#{user.ms_id}?locale=en")
      end
    end
  end

  describe '#remove_batch_submission_contributor' do
    context 'current user is not an admin' do
      before do
        sign_in user
      end

      it 'returns a 204' do
        post :remove_batch_submission_contributor, params: params
        expect(response.status).to eq(204)
      end
    end

    context 'current user is an admin' do
      before do
        batch_submission_contributors.users << user
        batch_submission_contributors.save
        admins.users << admin
        admins.save
        sign_in admin
      end

      it 'removes the user as a batch_submission_contributor' do
        post :remove_batch_submission_contributor, params: params
        expect(user.batch_submission_contributor?).to be(false)
        expect(response).to redirect_to("http://test.host/users/#{user.ms_id}?locale=en")
      end
    end
  end
end
