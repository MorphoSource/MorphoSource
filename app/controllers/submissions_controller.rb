class SubmissionsController < ApplicationController

  load_and_authorize_resource

  before_action :instantiate_work_forms

  def new
    session[:submission] ||= {}
    @submission = Submission.new(session[:submission])
  end

  def create
    reinstantiate_submission
    if params['biospec_search'].present?
      store_submission
      @docs = search_biospec
      render 'biospec'
    elsif params['biospec_select'].present?
      session[:submission][:biospec_id] = submission_params[:biospec_id]
      store_submission
      render 'device'
    elsif params['institution_select'].present?
      session[:submission][:institution_id] = submission_params[:institution_id]
      store_submission
      render 'device'
    elsif params['device_select'].present?
      session[:submission][:device_id] = submission_params[:device_id]
      store_submission
      render 'image_capture'
    else
      finish_submission
    end
  end

  def stage_biological_specimen
    reinstantiate_submission
    @submission.biospec_id = 'new'
    store_submission
    biospec_model_params = Hyrax::BiologicalSpecimenForm.model_attributes(params[:biological_specimen])
    session[:submission_biospec_create_params] = biospec_model_params
    render 'institution'
  end

  def stage_device
    reinstantiate_submission
    @submission.device_id = 'new'
    store_submission
    device_model_params = Hyrax::DeviceForm.model_attributes(params[:device])
    session[:submission_device_create_params] = device_model_params
    render 'image_capture'
  end

  def stage_imaging_event
    reinstantiate_submission
    @submission.imaging_event_id = 'new'
    store_submission
    imaging_event_model_params = Hyrax::ImagingEventForm.model_attributes(params[:imaging_event])
    session[:submission_imaging_event_create_params] = imaging_event_model_params
    render 'media'
  end

  def stage_institution
    reinstantiate_submission
    @submission.institution_id = 'new'
    store_submission
    institution_model_params = Hyrax::InstitutionForm.model_attributes(params[:institution])
    session[:submission_institution_create_params] = institution_model_params
    render 'device'
  end

  def stage_media
    reinstantiate_submission
    @submission.media_id = 'new'
    store_submission
    media_model_params = Hyrax::MediaForm.model_attributes(params[:media])
    media_uploaded_files = params[:uploaded_files]
    session[:submission_media_create_params] = media_model_params
    session[:submission_media_uploaded_files] = media_uploaded_files
    finish_submission
  end

  def finish_submission
    reinstantiate_submission
    # The various object '_create_params' are defined as instance variables so they are available to the
    # placeholder 'show' page for debugging purposes.  If they are not needed for that, they can become local
    # variables in this method instead.
    @biospec_create_params = session[:submission_biospec_create_params]
    @imaging_event_create_params = session[:submission_imaging_event_create_params]
    @institution_create_params = session[:submission_institution_create_params]
    @device_create_params = session[:submission_device_create_params]
    @media_create_params = session[:submission_media_create_params]
    media_uploaded_files = session[:submission_media_uploaded_files]
    if @institution_create_params.present?
      @submission.institution_id = create_institution(@institution_create_params)
    end
    if @biospec_create_params.present?
      @submission.biospec_id = create_biological_specimen(@biospec_create_params)
    end
    if @device_create_params.present?
      @submission.device_id = create_device(@device_create_params)
    end
    if @imaging_event_create_params.present?
      @submission.imaging_event_id = create_imaging_event(@imaging_event_create_params)
    end
    if @media_create_params.present?
      @submission.media_id = create_media(@media_create_params, media_uploaded_files)
    end
    clear_session_submission_settings
    render 'show'
  end

  def create_biological_specimen(params)
    parent_attributes = {}
    if @submission.institution_id.present?
      parent_attributes.merge!({ '0' => { "id" => @submission.institution_id, "_destroy" => "false" } })
    end
    unless parent_attributes.empty?
      params.merge!('work_parents_attributes' => parent_attributes)
    end
    create_work(BiologicalSpecimen, params)
  end

  def create_device(params)
    create_work(Device, params)
  end

  def create_imaging_event(params)
    parent_attributes = {}
    if @submission.biospec_id.present?
      parent_attributes.merge!({ '0' => { "id" => @submission.biospec_id, "_destroy" => "false" } })
    end
    if @submission.device_id.present?
      parent_attributes.merge!({ '1' => { "id" => @submission.device_id, "_destroy" => "false" } })
    end
    unless parent_attributes.empty?
      params.merge!('work_parents_attributes' => parent_attributes)
    end
    create_work(ImagingEvent, params)
  end

  def create_institution(params)
    create_work(Institution, params)
  end

  def create_media(params, uploaded_files)
    parent_attributes = {}
    if @submission.imaging_event_id.present?
      parent_attributes.merge!({ '0' => { "id" => @submission.imaging_event_id, "_destroy" => "false" } })
    end
    unless parent_attributes.empty?
      params.merge!('work_parents_attributes' => parent_attributes)
    end
    if uploaded_files.present?
      params.merge!({ uploaded_files: uploaded_files })
    end
    create_work(Media, @media_create_params)
  end

  private

  def clear_session_submission_settings
    session[:submission] = nil
    session[:submission_biospec_create_params] = nil
    session[:submission_device_create_params] = nil
    session[:submission_imaging_event_create_params] = nil
    session[:submission_institution_create_params] = nil
    session[:submission_media_create_params] = nil
  end

  def create_work(model, form_params)
    curation_concern = model.new
    attributes_for_actor = form_params
    unless model == Media
      attributes_for_actor.merge!({ visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC })
    end
    env = Hyrax::Actors::Environment.new(curation_concern, current_ability, attributes_for_actor)
    Hyrax::CurationConcern.actor.create(env)
    curation_concern.id
  end

  def instantiate_work_forms
    @biological_specimen_form = Hyrax::WorkFormService.build(BiologicalSpecimen.new, current_ability, self)
    @device_form = Hyrax::WorkFormService.build(Device.new, current_ability, self)
    @imaging_event_form = Hyrax::WorkFormService.build(ImagingEvent.new, current_ability, self)
    @institution_form = Hyrax::WorkFormService.build(Institution.new, current_ability, self)
    @media_form = Hyrax::WorkFormService.build(Media.new, current_ability, self)
  end

  def reinstantiate_submission
    session[:submission].deep_merge!(submission_params) if params[:submission]
    @submission = Submission.new(session[:submission])
  end

  def search_biospec
    search_params = {}
    biospec_search_params = submission_params.select{ |k,v| k.match(/^biospec_search_/) }.select{ |k,v| v.present? }
    biospec_search_params.each do |k,v|
      search_params[k.sub('biospec_search_', '')] = v
    end
    Morphosource::PhysicalObjectsSearchService.call(BiologicalSpecimen, search_params)
  end

  def store_submission
    session[:submission] = { biospec_id: @submission.biospec_id,
                             biospec_or_cho: @submission.biospec_or_cho,
                             device_id: @submission.device_id,
                             institution_id: @submission.institution_id,
                             raw_or_derived_media: @submission.raw_or_derived_media }
  end

  def submission_params
    params.fetch(:submission, {}).permit(:biospec_id,
                                         :biospec_or_cho,
                                         :biospec_search_catalog_number,
                                         :biospec_search_collection_code,
                                         :biospec_search_institution_code,
                                         :biospec_search_occurrence_id,
                                         :device_id,
                                         :imaging_event_id,
                                         :institution_id,
                                         :media_id,
                                         :raw_or_derived_media)
  end
end
