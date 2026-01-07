require 'rails_helper'

RSpec.describe BatchSubmissionsController, type: :controller do
  let(:user)                       { User.create(email: 'email@email.com', password: 'password', sftp_share: '/tmp') }
  let(:user2)                      { User.create(email: 'email2@email.com', password: 'password', sftp_share: '') }
  let(:user3)                      { User.create(email: 'email3@email.com', password: 'password', sftp_share: '/dir_not_found') }
  let(:user4)                      { User.create(email: 'email4@email.com', password: 'password', sftp_share: '/tmp') }
  let(:batch_submission_contributors)  { Role.create(name: 'batch_submission_contributor') }
  let(:image_file_path)             { fixture_path + '/images/duke.png' }
  let(:manifest_file_path)             { fixture_path + '/batch_submission_manifest_errors_test.xlsx' }
  let(:invalid_columns_file_path)             { fixture_path + '/batch_submission_manifest_errors_columns.xlsx' }
  let(:invalid_fields_file_path)             { fixture_path + '/batch_submission_manifest_errors_invalid_field.xlsx' }
  let(:invalid_parents_file_path)             { fixture_path + '/batch_submission_manifest_errors_parents.xlsx' }
  let(:invalid_file)         { Rack::Test::UploadedFile.new(image_file_path) }
  let(:valid_file)         { Rack::Test::UploadedFile.new(manifest_file_path) }
  let(:invalid_columns_file)         { Rack::Test::UploadedFile.new(invalid_columns_file_path) }
  let(:invalid_fields_file)         { Rack::Test::UploadedFile.new(invalid_fields_file_path) }
  let(:invalid_parents_file)         { Rack::Test::UploadedFile.new(invalid_parents_file_path) }

  before do
    batch_submission_contributors.users << [user, user3]
    batch_submission_contributors.save
  end

  describe "GET #new for batch_submission_contributor" do
    before do
      sign_in user
    end
    it "returns http success for batch_submission_contributor" do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "User has queued or working job running" do
    before do
      sign_in user
    end
    context "render index page" do
      render_views
      it "returns only one job allowed message" do
        BackgroundJob.create({ job_id: '123', status: 'queued', user_id: user.user_key, created_objects: {} })
        get :index
        expect(response.body).to include 'Only one batch submission job is allowed at a time.'
      end
    end
    context "render new submission page" do
      render_views
      it "returns currently have job running message" do
        BackgroundJob.create({ job_id: '234', status: 'working', user_id: user.user_key, created_objects: {} })
        get :new
        expect(response.body).to include 'Sorry, you currently have a batch submission job running.'
      end
    end
    context "post new submission" do
      render_views
      let(:params) { {"manifest" => valid_file,
        "batch_submission" => {
          "modality" => "MicroNanoXRayComputedTomography"
        }
      } }
      it "returns" do
        BackgroundJob.create({ job_id: '456', status: 'working', user_id: user.user_key, created_objects: {} })
        post 'submit', :params => params
        expect(response.body).to include 'Sorry, you currently have a batch submission job running.'
      end
    end
    context "proceed with ingest" do
      render_views
      let(:params) { {"manifest_object" => {}} }
      it "returns" do
        BackgroundJob.create({ job_id: '456', status: 'working', user_id: user.user_key, created_objects: {} })
        post 'ingest', :params => params
        expect(response.body).to include 'Sorry, you currently have a batch submission job running.'
      end
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

  describe "User SFTP share not linked" do
    before do
      sign_in user3
    end
    it "render not_connected page" do
      get :new
      expect(response).to render_template 'not_allowed'
    end
  end

  describe "User with no batch_submission_contributor access" do
    before do
      sign_in user4
    end
    it "redirected for index" do
      get :index
      expect(response).to have_http_status(302)
    end
    it "redirected for new submission" do
      get :new
      expect(response).to have_http_status(302)
    end
  end

  describe "POST submit result" do
    let (:organization) { create(:organization_collection, institution_code: ['abc']) }

    before do
      sign_in user
    end

    context "manifest file not present" do
      let(:params) { {"manifest" => nil} }
      it "redirected back to new" do
        post 'submit', :params => params
        expect(response).to redirect_to "/batch_submissions/new?locale=en"
      end
    end
    context "manifest format not valid" do
      let(:params) { {"manifest" => invalid_file} }
      it "redirected back to new" do
        post 'submit', :params => params
        expect(response).to redirect_to "/batch_submissions/new?locale=en"
      end
    end
    context "modality not present" do
      let(:params) { {"manifest" => valid_file, "batch_submission" => {"modality" => ""}} }
      it "redirected back to new" do
        post 'submit', :params => params
        expect(response).to redirect_to "/batch_submissions/new?locale=en"
      end
    end

  end
end
