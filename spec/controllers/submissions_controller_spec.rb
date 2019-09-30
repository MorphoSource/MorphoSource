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

    describe 'institution_select when creating new BSO' do
      let(:saved_step) {'biospec_will_create'}
      let(:institution_id) { 'abc123' }
      let(:form_params) { { submission: { institution_id: institution_id }, institution_select: 'foo' } }
      before do
        @request.session['submission'] = {saved_step: saved_step}
      end
      it 'sets the institution id in the session' do
        post :create, params: form_params
        expect(@request.session[:submission]).to include({ institution_id: institution_id })
      end
      it 'renders the biospec create view' do
        post :create, params: form_params
        expect(response).to render_template(:taxonomy)
      end
    end

    describe 'device_institution_select when creating new device' do
      let(:saved_step) {'device_will_create'}
      let(:institution_id) { 'abc123' }
      let(:form_params) { { submission: { device_institution_id: institution_id }, institution_select: 'foo' } }
      before do
        @request.session['submission'] = {saved_step: saved_step}
      end
      it 'sets the device institution id in the session' do
        post :create, params: form_params
        expect(@request.session[:submission]).to include({ device_institution_id: institution_id })
      end
      it 'renders the device create view' do
        post :create, params: form_params
        expect(response).to render_template(:device_create)
      end
    end

    describe 'institution_select when creating new CHO' do
      let(:saved_step) {'cho_will_create'}
      let(:institution_id) { 'abc123' }
      let(:form_params) { { submission: { institution_id: institution_id }, institution_select: 'foo' } }
      before do
        @request.session['submission'] = {saved_step: saved_step}
      end
      it 'sets the institution id in the session' do
        post :create, params: form_params
        expect(@request.session[:submission]).to include({ institution_id: institution_id })
      end
      it 'renders the CHO create view' do
        post :create, params: form_params
        expect(response).to render_template(:cho_create)
      end
    end

    describe 'device_select' do
      before do
        Device.create({
            id: 'abc123',
            title: ['XTekCT 100'],
            creator: ['Nikon'],
            modality: ['MedicalXRayComputedTomography'],
            facility: ['Duke SMIF'],
            description: ['A sample description']
        })
        @request.session['submission'] = {}
      end
      let(:device_id) { 'abc123' }
      let(:form_params) { { submission: { device_id: device_id }, device_select: 'XTekCT 100' } }

      it 'sets the device id in the session' do
        post :create, params: form_params
        expect(@request.session[:submission]).to include({ device_id: device_id })
      end

      it 'sets modality_to_set in cookie' do
        post :create, params: form_params
        expect(response.cookies["modality_to_set"]).to eq('MedicalXRayComputedTomography')
      end

      it 'renders the device view' do
        post :create, params: form_params
        expect(response).to render_template(:image_capture)
      end
    end

    describe 'parent_media_select' do
      before do
        Media.create({
            id: 'abc123',
            title: ['media 1'],
            modality: ['MedicalXRayComputedTomography']
        })
        @request.session['submission'] = {}
      end
      let(:media_id) { 'abc123' }
      let(:form_params) { { submission: { parent_media_list: 'abc123' }, parent_media_select: 'media 1' } }

      it 'sets modality_to_set in cookie' do
        post :create, params: form_params
        expect(response.cookies["modality_to_set"]).to eq('MedicalXRayComputedTomography')
      end

      it 'renders the processing event' do
        post :create, params: form_params
        expect(response).to render_template(:processing_event)
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
      expect(response).to render_template(:device)
    end
  end

  describe '#stage_device' do
    let(:form_attributes) do
      { 'title' => 'Device', 'creator' => [ 'Panasonic' ], 'modality' => [ 'Photography' ] }
    end
    let(:form_params) { { device: form_attributes } }
    let(:model_attributes) { form_attributes.transform_values { |value| Array(value) } }
    it 'stores the model attributes in the session' do
      post :stage_device, params: form_params
      expect(@request.session[:submission_device_create_params]).to include(model_attributes)
    end
    it 'sets modality_to_set in cookie' do
      post :stage_device, params: form_params
      expect(response.cookies["modality_to_set"]).to eq('Photography')
    end
    it 'renders the image_capture view' do
      post :stage_device, params: form_params
      expect(response).to render_template(:image_capture)
    end
  end

  describe '#stage_imaging_event' do
    let(:form_attributes) do
      { 'ie_modality' => 'NeutrinoImaging' }
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

  describe '#stage_institution when creating new biospec' do
    let(:saved_step) {'biospec_will_create'}
    before do
      @request.session['submission'] = {saved_step: saved_step}
    end
    let(:form_attributes) do
      { 'title' => 'Institution', 'institution_code' => 'inst' }
    end
    let(:form_params) { { institution: form_attributes } }
    let(:model_attributes) { form_attributes.transform_values { |value| Array(value) } }
    it 'stores the model attributes in the session' do
      post :stage_institution, params: form_params
      expect(@request.session[:submission_institution_create_params]).to include(model_attributes)
    end
    it 'renders the taxonomy page' do
      post :stage_institution, params: form_params
      expect(response).to render_template(:taxonomy)
    end
  end

  describe '#stage_device_institution when creating new device' do
    let(:saved_step) {'device_will_create'}
    before do
      @request.session['submission'] = {saved_step: saved_step}
    end
    let(:form_attributes) do
      { 'title' => 'Institution', 'institution_code' => 'inst' }
    end
    let(:form_params) { { institution: form_attributes } }
    let(:model_attributes) { form_attributes.transform_values { |value| Array(value) } }
    it 'stores the model attributes in the session' do
      post :stage_device_institution, params: form_params
      expect(@request.session[:submission_device_institution_create_params]).to include(model_attributes)
    end
    it 'renders the device create view' do
      post :stage_device_institution, params: form_params
      expect(response).to render_template(:device_create)
    end
  end

  describe '#stage_institution when creating new cho' do
    let(:saved_step) {'cho_will_create'}
    before do
      @request.session['submission'] = {saved_step: saved_step}
    end
    let(:form_attributes) do
      { 'title' => 'Institution', 'institution_code' => 'inst' }
    end
    let(:form_params) { { institution: form_attributes } }
    let(:model_attributes) { form_attributes.transform_values { |value| Array(value) } }
    it 'stores the model attributes in the session' do
      post :stage_institution, params: form_params
      expect(@request.session[:submission_institution_create_params]).to include(model_attributes)
    end
    it 'renders the cho create view' do
      post :stage_institution, params: form_params
      expect(response).to render_template(:cho_create)
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

  describe '#stage_taxonomy' do
    let(:saved_step) {'biospec_institution_select'}
    before do
      @request.session['submission'] = {saved_step: saved_step}
    end
    let(:form_attributes) do
      { "taxonomy_domain"=> "domain", "taxonomy_kingdom"=> "kingdom", "taxonomy_phylum"=> "phylum", "taxonomy_superclass"=> "superclass", "taxonomy_class"=> "class", "taxonomy_subclass"=> "subclass", "taxonomy_superorder"=> "superorder", "taxonomy_order"=> "order", "taxonomy_suborder"=> "suborder", "taxonomy_superfamily"=> "superfamily", "taxonomy_family"=> "family", "taxonomy_subfamily"=> "subfamily", "taxonomy_tribe"=> "tribe", "taxonomy_genus"=> "genus", "taxonomy_subgenus"=> "subgenus", "taxonomy_species"=> "species", "taxonomy_subspecies"=> "subspecies"}
    end
    let(:form_params) { { taxonomy: form_attributes } }
    let(:model_attributes) { form_attributes.transform_values { |value| Array(value) } }
    it 'stores the model attributes in the session' do
      post :stage_taxonomy, params: form_params
      expect(@request.session[:submission_taxonomy_create_params]).to include(model_attributes)
    end
    it 'renders the biospec create view' do
      post :stage_taxonomy, params: form_params
      expect(response).to render_template(:biospec_create)
    end
  end

  describe '#new_institution_submit' do
    describe 'successfully created a new institution' do
      let(:form_attributes) do
        { 'id' => 'abc', 
          'title' => 'Institution', 
          'institution_code' => 'inst',
          'description' => 'test', 
          'address' => 'test',
          'city' => 'test',
          'state_province' => 'test',
          'country' => 'test'
        }
      end
      let(:form_params) { { institution: form_attributes } }
      it 'return institution data in json response' do
        post :new_institution_submit, params: form_params
        
        expect(JSON.parse(response.body)).to include_json(
          status: 'OK',
          message: 'New institution created',
          work: {
            title: 'Institution',
            institution_code: 'inst',
            description: 'test', 
            address: 'test',
            city: 'test',
            state_province: 'test',
            country: 'test'
          }
        )
      end
    end

    describe 'failed to create a new institution' do
      let(:form_params) { { institution: {} } } # no form attribute will throw an exception
      it 'return failure status in json response' do
        post :new_institution_submit, params: form_params
        
        expect(JSON.parse(response.body)).to include_json(
          status: 'FAIL',
          message: 'There is a problem creating the institution.',
          work: {}
        )
      end
    end
  end

  describe '#new_taxonomy_submit' do
    describe 'successfully created a new taxonomy' do
      let(:form_attributes) do
        { 'taxonomy_domain' => '1', 'taxonomy_kingdom' => '1', 'taxonomy_phylum' => '1', 'taxonomy_superclass' => '1', 'taxonomy_class' => '1', 'taxonomy_subclass' => '1', 'taxonomy_superorder' => '1', 'taxonomy_order' => '1', 'taxonomy_suborder' => '1', 'taxonomy_superfamily' => '1', 'taxonomy_family' => '1', 'taxonomy_subfamily' => '1', 'taxonomy_tribe' => '1', 'taxonomy_genus' => '1', 'taxonomy_subgenus' => '1', 'taxonomy_species' => '1', 'taxonomy_subspecies' => '1'
        }
      end
      let(:form_params) { { taxonomy: form_attributes } }
      it 'return taxonomy data in json response' do
        post :new_taxonomy_submit, params: form_params
        
        expect(JSON.parse(response.body)).to include_json(
          status: 'OK',
          message: 'New Taxonomy created',
          work: {
            title: "1 > 1 > 1 > 1 > 1 > 1 > 1 > 1 > 1 > 1 > 1 > 1 > 1 > 1 > 1 > 1 > 1",
            taxonomy_domain:  '1', taxonomy_kingdom:  '1', taxonomy_phylum:  '1', taxonomy_superclass:  '1', taxonomy_class:  '1', taxonomy_subclass:  '1', taxonomy_superorder:  '1', taxonomy_order:  '1', taxonomy_suborder:  '1', taxonomy_superfamily:  '1', taxonomy_family:  '1', taxonomy_subfamily:  '1', taxonomy_tribe:  '1', taxonomy_genus:  '1', taxonomy_subgenus:  '1', taxonomy_species:  '1', taxonomy_subspecies:  '1'
          }
        )
      end
    end

    describe 'failed to create a new taxonomy' do
      let(:form_params) { { taxonomy: {} } } # no form attribute will throw an exception
      it 'return failure status in json response' do
        post :new_taxonomy_submit, params: form_params
        
        expect(JSON.parse(response.body)).to include_json(
          status: 'FAIL',
          message: 'There is a problem creating the taxonomy.',
          work: {}
        )
      end
    end
  end

end
