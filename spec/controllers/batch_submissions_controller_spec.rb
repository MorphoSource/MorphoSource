require 'rails_helper'

RSpec.describe BatchSubmissionsController, type: :controller do
  let(:user)                       { User.create(email: 'email@email.com', password: 'password', sftp_share: '/tmp') }
  let(:user2)                      { User.create(email: 'email2@email.com', password: 'password', sftp_share: '') }
  let(:admins)                     { Role.create(name: 'admin') }
  let(:batch_submission_contributors)  { Role.create(name: 'batch_submission_contributor') }

  before do
    batch_submission_contributors.users << user
    batch_submission_contributors.save
  end

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

  describe "GET submit" do
    subject {get :submit}
    let(:params) { {"manifest" => nil} }

    context "params not present" do
      before do
        sign_in user
        subject.instance_variable_set(:@params, params)
      end
      it "redirected back to new" do
        expect(response).to redirect_to "/batch_submissions/new?locale=en"
      end
    end
  end

#      context "Not found"
#      before do
#        sign_in user
#      end
#      it "user_share_full_path NOT FOUND" do
#        expect(subject).to eq('NOT_FOUND')
#      end

end
