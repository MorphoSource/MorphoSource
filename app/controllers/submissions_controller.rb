class SubmissionsController < ApplicationController

  load_and_authorize_resource

  before_action :instantiate_work_forms

  def new
    session[:submission] ||= {}
    @submission = Submission.new(session[:submission])
  end

  def create
    case
    when params[:start_over]
      start_over
    when params[:previous_button]
      reinstantiate_submission
      step_back
    else
      reinstantiate_submission
      if @submission.valid?
        valid_submission
      else
        store_submission
        render 'new'
      end
    end
  end

  def create_biological_specimen
    reinstantiate_submission
    model_params = Hyrax::BiologicalSpecimenForm.model_attributes(params[:biological_specimen])
    @submission.object_id = create_work(BiologicalSpecimen, model_params)
    step_forward
  end

  def create_cultural_heritage_object
    reinstantiate_submission
    model_params = Hyrax::CulturalHeritageObjectForm.model_attributes(params[:cultural_heritage_object])
    @submission.object_id = create_work(CulturalHeritageObject, model_params)
    step_forward
  end

  def create_institution
    reinstantiate_submission
    model_params = Hyrax::InstitutionForm.model_attributes(params[:institution])
    @submission.institution_id = create_work(Institution, model_params)
    step_forward
  end

  private

  def clear_session_submission_settings
    session[:submission] = nil
  end

  def create_work(model, form_params)
    curation_concern = model.new
    attributes_for_actor = form_params.merge({ visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC })
    env = Hyrax::Actors::Environment.new(curation_concern, current_ability, attributes_for_actor)
    Hyrax::CurationConcern.actor.create(env)
    curation_concern.id
  end

  def finish_submission
    if @submission.all_valid?
      clear_session_submission_settings
      redirect_to [ main_app, :new, :hyrax, :parent, 'media', parent_id: @submission.imaging_event_id ]
    else
      store_submission
      render 'new'
    end
  end

  def instantiate_work_forms
    @institution_form = Hyrax::WorkFormService.build(Institution.new, current_ability, self)
    @biological_specimen_form = Hyrax::WorkFormService.build(BiologicalSpecimen.new, current_ability, self)
    @cultural_heritage_object_form = Hyrax::WorkFormService.build(CulturalHeritageObject.new, current_ability, self)
  end

  def reinstantiate_submission
    step_name = session[:submission].delete('current_step')
    session[:submission].deep_merge!(submission_params) if params[:submission]
    @submission = Submission.new(session[:submission])
    @submission.current_step = Submission.step(step_name)
  end

  def store_submission
    step = @submission.current_step.name
    session[:submission] = { 'current_step' => step,
                             'imaging_event_id' => @submission.imaging_event_id,
                             'institution_id' => @submission.institution_id,
                             'object_id' => @submission.object_id }
  end

  def start_over
    clear_session_submission_settings
    redirect_to new_submission_path
  end

  def step_back
    @submission.step_back
    store_submission
    render 'new'
  end

  def step_forward
    @submission.step_forward
    store_submission
    render 'new'
  end

  def submission_params
    params.fetch(:submission, {}).permit(:imaging_event_id, :institution_id, :object_id)
  end

  def valid_submission
    if @submission.last_step?
      finish_submission
    else
      step_forward
    end
  end

end
