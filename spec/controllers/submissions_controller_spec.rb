require 'rails_helper'

RSpec.describe SubmissionsController, type: :controller do

  let(:user) { FactoryBot.create(:user) }

  before do
    sign_in user
  end

  describe 'new' do
    it 'sets the current step to the first step' do
      get :new
      expect(assigns[:submission].current_step).to eq(Submission.first_step)
    end
  end

  describe 'create' do
    let(:institution_id) { 'foo' }
    let(:object_id) { 'bar' }
    let(:imaging_event_id) { 'baz' }
    describe 'institution page submission' do
      describe 'institution selected' do
        let(:form_params) { { submission: { institution_id: institution_id } } }
        before do
          @request.session['submission'] = {}
        end
        it 'instantiates a submission with the institution ID' do
          post :create, params: form_params
          expect(assigns[:submission].institution_id).to eq(institution_id)
        end
        it 'stores the institution ID in the session' do
          post :create, params: form_params
          expect(session['submission']).to include({ 'institution_id' => institution_id })
        end
        it 'sets the next step correctly' do
          post :create, params: form_params
          expect(session['submission']['current_step']).to eq(Submission::STEP_OBJECT.name)
        end
      end
      describe 'institution not selected' do
        let(:form_params) { { submission: { institution_id: nil } } }
        before do
          @request.session['submission'] = {}
        end
        it 'does not advance the step' do
          post :create, params: form_params
          expect(session['submission']['current_step']).to eq(Submission::STEP_INSTITUTION.name)
        end
        it 'renders the new template' do
          post :create, params: form_params
          expect(response).to render_template('new')
        end
      end
    end
    describe 'object page submission' do
      describe 'object selected' do
        let(:form_params) { { submission: { object_id: object_id } } }
        before do
          @request.session['submission'] = { 'current_step' => Submission::STEP_OBJECT.name,
                                             'institution_id' => institution_id }
        end
        it 'instantiates a submission with the institution ID and object ID' do
          post :create, params: form_params
          expect(assigns[:submission].institution_id).to eq(institution_id)
          expect(assigns[:submission].object_id).to eq(object_id)
        end
        it 'stores the institution ID and object ID in the session' do
          post :create, params: form_params
          expect(session['submission']).to include({ 'institution_id' => institution_id, 'object_id' => object_id })
        end
        it 'sets the next step correctly' do
          post :create, params: form_params
          expect(session['submission']['current_step']).to eq(Submission::STEP_IMAGING_EVENT.name)
        end
      end
      describe 'object not selected' do
        let(:form_params) { { submission: { object_id: nil } } }
        before do
          @request.session['submission'] = { 'current_step' => Submission::STEP_OBJECT.name,
                                             'institution_id' => institution_id }
        end
        it 'does not advance the step' do
          post :create, params: form_params
          expect(session['submission']['current_step']).to eq(Submission::STEP_OBJECT.name)
        end
        it 'renders the new template' do
          post :create, params: form_params
          expect(response).to render_template('new')
        end
      end
      describe 'previous button' do
        let(:form_params) { { submission: { object_id: nil } } }
        before do
          @request.session['submission'] = { 'current_step' => Submission::STEP_OBJECT.name,
                                             'institution_id' => institution_id }
        end
        it 'backs up one step' do
          post :create, params: form_params.merge({ previous_button: 'Back to previous step' })
          expect(session['submission']['current_step']).to eq(Submission::STEP_INSTITUTION.name)
        end
      end
      describe 'start over button' do
        let(:form_params) { { submission: { object_id: nil } } }
        before do
          @request.session['submission'] = { 'current_step' => Submission::STEP_OBJECT.name,
                                             'institution_id' => institution_id }
        end
        it 'clears the submission session params' do
          post :create, params: form_params.merge({ start_over: 'Start over' })
          expect(session['submission']).to be nil
        end
      end
    end
    describe 'imaging event page submission' do
      describe 'imaging event selected' do
        let(:form_params) { { submission: { imaging_event_id: imaging_event_id } } }
        before do
          @request.session['submission'] = { 'current_step' => Submission::STEP_IMAGING_EVENT.name,
                                             'institution_id' => institution_id,
                                             'object_id' => object_id }
        end
        it 'instantiates a submission with the institution ID, object ID, and imaging event ID' do
          post :create, params: form_params
          expect(assigns[:submission].institution_id).to eq(institution_id)
          expect(assigns[:submission].object_id).to eq(object_id)
          expect(assigns[:submission].imaging_event_id).to eq(imaging_event_id)
        end
        it 'clears the submission session params' do
          post :create, params: form_params
          expect(session['submission']).to be nil
        end
      end
      describe 'imaging event not selected' do
        let(:form_params) { { submission: { imaging_event_id: nil } } }
        before do
          @request.session['submission'] = { 'current_step' => Submission::STEP_IMAGING_EVENT.name,
                                             'institution_id' => institution_id,
                                             'object_id' => object_id }
        end
        it 'does not advance the step' do
          post :create, params: form_params
          expect(session['submission']['current_step']).to eq(Submission::STEP_IMAGING_EVENT.name)
        end
        it 'renders the new template' do
          post :create, params: form_params
          expect(response).to render_template('new')
        end
      end
      describe 'previous button' do
        let(:form_params) { { submission: { imaging_event_id: nil } } }
        before do
          @request.session['submission'] = { 'current_step' => Submission::STEP_IMAGING_EVENT.name,
                                             'institution_id' => institution_id,
                                             'object_id' => object_id }
        end
        it 'backs up one step' do
          post :create, params: form_params.merge({ previous_button: 'Back to previous step' })
          expect(session['submission']['current_step']).to eq(Submission::STEP_OBJECT.name)
        end
      end
      describe 'start over button' do
        let(:form_params) { { submission: { imaging_event_id: nil } } }
        before do
          @request.session['submission'] = { 'current_step' => Submission::STEP_IMAGING_EVENT.name,
                                             'institution_id' => institution_id,
                                             'object_id' => object_id }
        end
        it 'clears the submission session params' do
          post :create, params: form_params.merge({ start_over: 'Start over' })
          expect(session['submission']).to be nil
        end
      end
    end
  end
end
