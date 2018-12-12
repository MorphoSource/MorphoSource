require 'rails_helper'

RSpec.describe SubmissionsController, type: :controller do

  let(:user) { FactoryBot.create(:user) }

  before do
    sign_in user
  end

  describe '#create' do
    describe 'biospec_search' do
      let(:form_params) { { submission: {}, biospec_search: 'foo' } }
      it 'runs a biospec search' do
        expect(subject).to receive(:search_biospec)
        post :create, params: form_params
      end
      it 'renders the biospec view' do
        post :create, params: form_params
        expect(response).to render_template(:biospec)
      end
    end

    describe 'biospec_select' do
      let(:biospec_id) { 'abc123' }
      let(:form_params) { { submission: { biospec_id: biospec_id }, biospec_select: 'foo' } }
      before do
        @request.session['submission'] = {}
      end
      it 'sets the biospec id in the session' do
        post :create, params: form_params
        expect(@request.session[:submission]).to include({ biospec_id: biospec_id })
      end
      it 'renders the device view' do
        post :create, params: form_params
        expect(response).to render_template(:device)
      end
    end

    describe 'institution_select' do
      let(:institution_id) { 'abc123' }
      let(:form_params) { { submission: { institution_id: institution_id }, institution_select: 'foo' } }
      before do
        @request.session['submission'] = {}
      end
      it 'sets the institution id in the session' do
        post :create, params: form_params
        expect(@request.session[:submission]).to include({ institution_id: institution_id })
      end
      it 'renders the device view' do
        post :create, params: form_params
        expect(response).to render_template(:device)
      end
    end

    describe 'device_select' do
      let(:device_id) { 'abc123' }
      let(:form_params) { { submission: { device_id: device_id }, device_select: 'foo' } }
      before do
        @request.session['submission'] = {}
      end
      it 'sets the device id in the session' do
        post :create, params: form_params
        expect(@request.session[:submission]).to include({ device_id: device_id })
      end
      it 'renders the device view' do
        post :create, params: form_params
        expect(response).to render_template(:image_capture)
      end
    end

    describe 'default' do
      let(:form_params) { { submission: {} } }
      it 'finishes the submission' do
        expect(subject).to receive(:finish_submission)
        post :create, params: form_params
      end
    end
  end

  describe '#stage_biological_specimen' do
    let(:form_attributes) do
      { 'vouchered' => 'Yes', 'catalog_number' => '123', 'collection_code' => 'abc', 'creator' => [ 'Smith, Sam' ] }
    end
    let(:form_params) { { biological_specimen: form_attributes } }
    let(:model_attributes) { form_attributes.transform_values { |value| Array(value) } }
    it 'stores the model attributes in the session' do
      post :stage_biological_specimen, params: form_params
      expect(@request.session[:submission_biospec_create_params]).to include(model_attributes)
    end
    it 'renders the institution view' do
      post :stage_biological_specimen, params: form_params
      expect(response).to render_template(:institution)
    end
  end

  describe '#stage_device' do
    let(:form_attributes) do
      { 'title' => 'Device', 'creator' => [ 'Panasonic' ] }
    end
    let(:form_params) { { device: form_attributes } }
    let(:model_attributes) { form_attributes.transform_values { |value| Array(value) } }
    it 'stores the model attributes in the session' do
      post :stage_device, params: form_params
      expect(@request.session[:submission_device_create_params]).to include(model_attributes)
    end
    it 'renders the image_capture view' do
      post :stage_device, params: form_params
      expect(response).to render_template(:image_capture)
    end
  end

  describe '#stage_imaging_event' do
    let(:form_attributes) do
      { 'title' => 'Imaging Event', 'ie_modality' => 'NeutrinoImaging' }
    end
    let(:form_params) { { imaging_event: form_attributes } }
    let(:model_attributes) { form_attributes.transform_values { |value| Array(value) } }
    it 'stores the model attributes in the session' do
      post :stage_imaging_event, params: form_params
      expect(@request.session[:submission_imaging_event_create_params]).to include(model_attributes)
    end
    it 'renders the media view' do
      post :stage_imaging_event, params: form_params
      expect(response).to render_template(:media)
    end
  end

  describe '#stage_institution' do
    let(:form_attributes) do
      { 'title' => 'Institution', 'institution_code' => 'inst' }
    end
    let(:form_params) { { institution: form_attributes } }
    let(:model_attributes) { form_attributes.transform_values { |value| Array(value) } }
    it 'stores the model attributes in the session' do
      post :stage_institution, params: form_params
      expect(@request.session[:submission_institution_create_params]).to include(model_attributes)
    end
    it 'renders the media view' do
      post :stage_institution, params: form_params
      expect(response).to render_template(:device)
    end
  end

  describe '#stage_media' do
    let(:metadata_attributes) do
      { 'modality' => [ 'LaserScan', 'Infrared' ], 'media_type' => 'Mesh' }
    end
    let(:uploaded_files) { [ '12', '13' ] }
    let(:visibility) { 'authenticated' }
    let(:visibility_attribute) { { 'visibility' => visibility } }
    let(:form_params) { { media: metadata_attributes.merge(visibility_attribute), uploaded_files: uploaded_files } }
    let(:model_attributes) do
      metadata_attributes.transform_values { |value| Array(value) }.merge(visibility_attribute)
    end
    describe 'session storage' do
      before { allow(subject).to receive(:finish_submission) { nil } }
      it 'stores the model attributes in the session' do
        post :stage_media, params: form_params
        expect(@request.session[:submission_media_create_params]).to include(model_attributes)
      end
      it 'stores the uploaded files in the session' do
        post :stage_media, params: form_params
        expect(@request.session[:submission_media_uploaded_files]).to include(*uploaded_files)
      end
    end
    describe 'next step' do
      it 'finishes the submission' do
        expect(subject).to receive(:finish_submission)
        post :stage_media, params: form_params
      end
    end
  end

end
