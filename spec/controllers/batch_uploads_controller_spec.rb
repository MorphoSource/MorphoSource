require 'rails_helper'

RSpec.describe BatchUploadsController, type: :controller do
  let(:user)                       { User.create(email: 'email@email.com', password: 'password') }
  let(:user2)                      { User.create(email: 'email2@email.com', password: 'password') }
  let(:admins)                     { Role.create(name: 'admin') }
  let(:batch_upload_contributors)  { Role.create(name: 'batch_upload_contributor') }

  describe "GET #new for batch_upload_contributor" do
    before do
      batch_upload_contributors.users << user
      batch_upload_contributors.save
      sign_in user
    end
    it "returns http success for batch_upload_contributor" do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #new for non-batch_upload_contributor" do
    before do
      sign_in user2
    end
    it "redirected for non-batch_upload_contributor" do
      get :new
      expect(response).to have_http_status(302)
    end
  end

end
