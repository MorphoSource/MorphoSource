require 'rails_helper'

RSpec.describe BatchSubmissionsController, type: :controller do
  let(:user)                       { User.create(email: 'email@email.com', password: 'password', sftp_share: '/tmp') }
  let(:user2)                      { User.create(email: 'email2@email.com', password: 'password', sftp_share: '') }
  let(:user3)                      { User.create(email: 'email3@email.com', password: 'password', sftp_share: '/dir_not_found') }
  let(:admins)                     { Role.create(name: 'admin') }
  let(:batch_submission_contributors)  { Role.create(name: 'batch_submission_contributor') }
  let(:image_file_path)             { fixture_path + '/images/duke.png' }
  let(:manifest_file_path)             { fixture_path + '/batch_submission_manifest_errors_test.xlsx' }
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
    let (:organization_recordset_id) {'xyz'}
    let (:organization_institution_code) {'abc'}
    before do
      sign_in user
    end
    context "result with error messages" do
      render_views

      context "result with MicroNanoXRayComputedTomography pre-selected" do
        let(:params) { {"manifest" => valid_file, 
          "organization_institution_code" => organization_institution_code,
          "organization_recordset_id" => organization_recordset_id,
          "batch_submission" => {
            "modality" => "MicroNanoXRayComputedTomography"
          }
        } }
        it "shows result with modality MicroNanoXRayComputedTomography pre-selected" do
          post 'submit', :params => params 
          expect(response).to render_template 'validation_fail'
          html = response.body
          expect(html).to include 'media.media_file: File ANSP_Fish_53046_Head.zip cannot be found. Please check your shared folder.'
          expect(html).to include 'media.media_type: Please enter a valid value: "Image", "Video", "CTImageSeries", "PhotogrammetryImageSeries", "Mesh", "Other"'
          expect(html).to include 'One of the following must have a value: biological_specimen.ms_id, biological_specimen.idigbio_uuid, biological_specimen.occurrence_id, biological_specimen.institution_code, biological_specimen.collection_code, and biological_specimen.catalog_number.'
          expect(html).to include 'biological_specimen.date_created: Please enter a valid date in YYYY-MM-DD or MM-DD-YYYY format.'
          expect(html).to include 'biological_specimen.is_type_specimen: Please enter a valid value: "Yes", "No", "Y", "N", "true", "false", "0", "1"'
          expect(html).to include 'biological_specimen.sex: Please enter a valid value: "Female", "Male", "Unknowable", "Undetermined", "Hermaphrodite", "Gynandromorph"'
          expect(html).to include 'imaging_event.ct.exposure_time: Please enter a valid number.'
          expect(html).to include 'imaging_event.ct.target_type: Please enter a valid value: "Reflection", "Transmission"'
          expect(html).to include 'imaging_event.ct.detector_type: Please enter a valid value: "Direct (X-Ray photoconductor)", "Scintillator (Phosphor used)", "Storage (Storage Phosphor)", "Film (Scanned film/screen)"'
          expect(html).to include 'imaging_event.ct.detector_pixels_x: Please enter a valid integer.'
          expect(html).to include 'imaging_event.ct.detector_pixels_y: Please enter a valid integer.'
          expect(html).to include 'imaging_event.ct.detector_configuration: Please enter a valid value: "Area (single or tiled detector)", "Slot (scanned slot, slit, or spot)"'
          expect(html).to include 'imaging_event.ct.acquisition_type: Please enter a valid value: "ConstantAngle", "Free", "Sequenced", "Spiral", "Stationary"'
          expect(html).to include 'imaging_event.photogrammetry.focal_length_type: Value should not be present when modality MicroNanoXRayComputedTomography is pre-selected.'
          expect(html).to include 'imaging_event.photography.light_source: Value should not be present when modality MicroNanoXRayComputedTomography is pre-selected.'
          expect(html).to include 'media.y_spacing: Value should be present for media type CTImageSeries.'
          expect(html).to include 'media.z_spacing: Please enter a valid number.'
          expect(html).to include 'media.publication_status: Please enter a valid value: "Open", "RestrictedDownload", "Private"'
          expect(html).to include 'A value can be present in media.parent_file or media.parent_ms_id, but not in both.'
          expect(html).to include 'media.parent_ms_id: Existing media not_found not found.'
          expect(html).to include 'biological_specimen.ms_id: Existing biological specimen not_found not found.'
          expect(html).to include 'biological_specimen.idigbio_uuid: Cannot found specimen in iDigBio.'
          expect(html).to include 'biological_specimen.institution_code: It does not match the institution code from the pre-selected organization: ' + organization_institution_code
          expect(html).to include 'media.parent_file parent_file_not_found.zip not found in another row.'
          expect(html).to include 'media.parent_file ANSP_Fish_193352_Head.zip cannot be media.media_file in the same row.'
          expect(html).to include 'Specimen in iDigBio has institution code cm which does not match the pre-selected organization\'s institution code: ' + organization_institution_code
          expect(html).to include 'Specimen in iDigBio has recordset id 71b8ffab-444e-43f9-9a9c-5c42b0eaa5eb which does not match the pre-selected organization\'s recordset id: ' + organization_recordset_id
        end
      end

      context "result with Photogrammetry pre-selected" do
        let(:params) { {"manifest" => valid_file, "batch_submission" => {"modality" => "Photogrammetry"}} }
        it "shows result with modality Photogrammetry pre-selected" do
          post 'submit', :params => params 
          expect(response).to render_template 'validation_fail'
          html = response.body
          expect(html).to include 'imaging_event.ct.exposure_time: Value should not be present when modality Photogrammetry is pre-selected'
          expect(html).to include 'imaging_event.photogrammetry.focal_length_type: Please enter a valid value: "Variable", "Fixed"'
          expect(html).to include 'imaging_event.photography.light_source: Value should not be present when modality Photogrammetry is pre-selected.'
        end
      end

      context "result with Photography pre-selected" do
        let(:params) { {"manifest" => valid_file, "batch_submission" => {"modality" => "Photography"}} }
        it "shows result with modality Photography pre-selected" do
          post 'submit', :params => params 
          expect(response).to render_template 'validation_fail'
          html = response.body
          expect(html).to include 'imaging_event.ct.acquisition_type: Value should not be present when modality Photography is pre-selected.'
          expect(html).to include 'imaging_event.photogrammetry.focal_length_type: Value should not be present when modality Photography is pre-selected.'
          expect(html).to include 'imaging_event.photography.light_source: Please enter a valid value: "Strobe", "Static", "Patterned", "Cross polarized"'
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
