require 'rails_helper'

RSpec.describe BatchSubmissionsController, type: :controller do
  let(:user)                       { User.create(email: 'email@email.com', password: 'password', sftp_share: '/tmp') }
  let(:user2)                      { User.create(email: 'email2@email.com', password: 'password', sftp_share: '') }
  let(:user3)                      { User.create(email: 'email3@email.com', password: 'password', sftp_share: '/dir_not_found') }
  let(:admins)                     { Role.create(name: 'admin') }
  let(:batch_submission_contributors)  { Role.create(name: 'batch_submission_contributor') }
  let(:image_file_path)             { fixture_path + '/images/duke.png' }
  let(:manifest_file_path)             { fixture_path + '/batch_submission_manifest_test.xlsx' }
  let(:invalid_file)         { Rack::Test::UploadedFile.new(image_file_path) }
  let(:valid_file)         { Rack::Test::UploadedFile.new(manifest_file_path) }

  before do
    batch_submission_contributors.users << [user, user3]
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

  describe "User SFTP share not linked" do
    before do
      sign_in user3
    end
    it "render not_connected page" do
      get :new
      expect(response).to render_template 'not_connected'
    end
  end

  describe "POST submit result" do
    before do
      sign_in user
    end
    context "result with error messages" do
      render_views

      context "result with MicroNanoXRayComputedTomography pre-selected" do
        let(:params) { {"manifest" => valid_file, "batch_submission" => {"modality" => "MicroNanoXRayComputedTomography"}} }
        it "shows result with modality MicroNanoXRayComputedTomography pre-selected" do
          post 'submit', :params => params 
          expect(response).to render_template 'result'
          expect(response.body).to include 'media.media_file: File ANSP_Fish_53046_Head.zip cannot be found. Please check your shared folder'
          expect(response.body).to include 'media.media_file: File ANSP_Fish_53046_Head.zip cannot be found. Please check your shared folder.'
          expect(response.body).to include 'media.media_type: Please enter a valid value: "Image", "Video", "CTImageSeries", "PhotogrammetryImageSeries", "Mesh", "Other"'
          expect(response.body).to include 'One of the following must have a value: biological_specimen.ms_id, biological_specimen.idigbio_uuid, biological_specimen.occurrence_id, biological_specimen.institution_code, biological_specimen.collection_code, and biological_specimen.catalog_number.'
          expect(response.body).to include 'biological_specimen.date_created: Please enter a valid date in YYYY-MM-DD or MM-DD-YYYY format.'
          expect(response.body).to include 'biological_specimen.is_type_specimen: Please enter a valid value: "Yes", "No", "Y", "N", "true", "false", "0", "1"'
          expect(response.body).to include 'biological_specimen.sex: Please enter a valid value: "Female", "Male", "Unknowable", "Undetermined", "Hermaphrodite", "Gynandromorph"'
          expect(response.body).to include 'imaging_event.ct.exposure_time: Please enter a valid number.'
          expect(response.body).to include 'imaging_event.ct.filter_material: Please enter a valid value: "Molybdenum", "Aluminum", "Copper", "Rhodium", "Niobium", "Europium", "Lead"'
          expect(response.body).to include 'imaging_event.ct.target_type: Please enter a valid value: "Reflection", "Transmission"'
          expect(response.body).to include 'imaging_event.ct.detector_type: Please enter a valid value: "Direct (X-Ray photoconductor)", "Scintillator (Phosphor used)", "Storage (Storage Phosphor)", "Film (Scanned film/screen)"'
          expect(response.body).to include 'imaging_event.ct.detector_pixels_x: Please enter a valid integer.'
          expect(response.body).to include 'imaging_event.ct.detector_pixels_y: Please enter a valid integer.'
          expect(response.body).to include 'imaging_event.ct.detector_configuration: Please enter a valid value: "Area (single or tiled detector)", "Slot (scanned slot, slit, or spot)"'
          expect(response.body).to include 'imaging_event.ct.acquisition_type: Please enter a valid value: "ConstantAngle", "Free", "Sequenced", "Spiral", "Stationary"'
          expect(response.body).to include 'imaging_event.photogrammetry.focal_length_type: Value should not be present when modality MicroNanoXRayComputedTomography is pre-selected.'
          expect(response.body).to include 'imaging_event.photography.light_source: Value should not be present when modality MicroNanoXRayComputedTomography is pre-selected.'
        end
      end

      context "result with Photogrammetry pre-selected" do
        let(:params) { {"manifest" => valid_file, "batch_submission" => {"modality" => "Photogrammetry"}} }
        it "shows result with modality Photogrammetry pre-selected" do
          post 'submit', :params => params 
          expect(response).to render_template 'result'
          expect(response.body).to include 'imaging_event.ct.exposure_time: Value should not be present when modality Photogrammetry is pre-selected'
          expect(response.body).to include 'imaging_event.photogrammetry.focal_length_type: Please enter a valid value: "Variable", "Fixed"'
          expect(response.body).to include 'imaging_event.photography.light_source: Value should not be present when modality Photogrammetry is pre-selected.'
        end
      end

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
    context "modailty not present" do
      let(:params) { {"manifest" => valid_file, "batch_submission" => {"modality" => ""}} }
      it "redirected back to new" do
        post 'submit', :params => params 
        expect(response).to redirect_to "/batch_submissions/new?locale=en"
      end
    end
  end

end
