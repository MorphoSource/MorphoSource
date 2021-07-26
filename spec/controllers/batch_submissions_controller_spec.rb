require 'rails_helper'

RSpec.describe BatchSubmissionsController, type: :controller do
  let(:user)                       { User.create(email: 'email@email.com', password: 'password') }
  let(:user2)                      { User.create(email: 'email2@email.com', password: 'password') }
  let(:admins)                     { Role.create(name: 'admin') }
  let(:batch_submission_contributors)  { Role.create(name: 'batch_submission_contributor') }

  describe "GET #new for batch_submission_contributor" do
    before do
      batch_submission_contributors.users << user
      batch_submission_contributors.save
      sign_in user
    end
    it "returns http success for batch_submission_contributor" do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #new for non-batch_submission_contributor" do
    before do
      sign_in user2
    end
    it "redirected for non-batch_submission_contributor" do
      get :new
      expect(response).to have_http_status(302)
    end
  end

end
