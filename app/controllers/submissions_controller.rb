require 'net/http'
require 'uri'
require 'json'

class SubmissionsController < ApplicationController
  # Adds Hyrax behaviors to the controller.
  include Hyrax::WorksControllerBehavior
  include MorphosourceHelper
  include Morphosource::LinkedTeams::LinkedTeamsManagement

  load_and_authorize_resource except: [:search_po_ajax, :get_organization, :get_device, :get_device_organization, :create2, :save_data]

  before_action :instantiate_work_forms

  # override the layout from WorksControllerBehavior
  def decide_layout
    layout = case action_name
             when 'new_organization'
               'embedded_page'
             when 'new_taxonomy'
               'embedded_page'
             else
               'submission'
             end
    File.join(theme, layout)
  end

  def new
    if params[:restart]
      clear_session_submission_settings
    end
    session[:submission] ||= {}
    form_data = session[:submission]['form_data'] ||= {}
    work_data = session[:submission]['work_data'] ||= {}

    @submission = Submission.new({
      form_data: form_data,
      work_data: work_data
    })
  end

  ### NEW METHODS ###

  def search_po_ajax
    @po_type = submission_params[:biological_specimen_or_cultural_heritage_object]
    if @po_type == 'bso'
      @docs = search_biospec
      @idigbio = search_idigbio
      @idigbio.reject!{|i| @docs.map{|d| d.idigbio_uuid}.flatten.compact.uniq.include?(i['uuid'])} unless (@docs.nil? || @idigbio.nil?)
    elsif @po_type == 'cho'
      @docs = search_cho
      @idigbio = []
    end
    respond_to do |format|
      format.js
    end
  end

  def get_organization
    @selected_organization = Organization.find(submission_params[:organization_id])
      .attributes.slice(
      'id', 'title', 'institution', 'institution_code', 'collection_code', 
      'address', 'city', 'state_province', 'country')
      .transform_values { |v| Array(v).first }
    respond_to do |format|
      format.js
    end
  end

  def get_device
    d = Device.find(submission_params[:device_id])
    @selected_device = d
      .attributes.slice('id', 'title', 'creator', 'modality', 'description')
      .merge('member_of' => d.member_of)
      .map {|k, v| k == 'member_of' ? ['organization_title', v.first.title.first] : [k, Array(v).join(', ')] }
      .to_h
    respond_to do |format|
      format.js
    end
  end

  def get_device_organization
    @selected_organization = Organization.find(submission_params[:device_organization_id])
      .attributes.slice(
      'id', 'title', 'institution', 'institution_code', 'collection_code', 
      'address', 'city', 'state_province', 'country')
      .transform_values { |v| Array(v).first }
    respond_to do |format|
      format.js
    end
  end

  def save_data
    save_params_to_session
  end

  def create2
    reinstantiate_submission

    byebug
    works.each do |work|
      puts("Creating #{work} if necessary")
      create_work_if_needed(work, params)
    end

    render 'show' 
  end

  def works
    ['organization', 'device_organization', 'taxonomy', 'biological_specimen', 
      'cultural_heritage_object', 'device', 'imaging_event', 'processing_event', 'media']
  end

  def create_work_if_needed(work, params)
    if !@submission.public_send(to_id(work)).present? && params[work]
      puts("Creating #{work}")
      @submission.public_send(to_id(work) + '=', prepare_and_create_work(work, params))
    end
  end

  def prepare_and_create_work(work, params)
    create_work(to_model(work), create_model_params(work, params))
  end

  def create_model_params(work, params)
    model_params = to_form(work).model_attributes(params[work])
    if work == 'media'
      finalize_model_params(work, model_params, { uploaded_files: params[:uploaded_files] } )
    else
      finalize_model_params(work, model_params)
    end
  end

  def finalize_model_params(work, model_params, addl_params={})
    case work
    when 'biological_specimen'
      model_params = assign_model_params_parents(
        model_params, 
        [@submission.organization_id, @submission.taxonomy_id])
      if @submission.canonical_taxonomy_id.present?
        model_params.merge!('canonical_taxonomy' => [@submission.canonical_taxonomy_id])
      end
      @biospec_create_params = model_params

    when 'cultural_heritage_object'
      model_params = assign_model_params_parents(
        model_params, 
        [@submission.organization_id])
      @cho_create_params = model_params

    when 'device'
      if @submission.device_organization_id == 'submission_organization'
        @submission.device_organization_id = @submission.organization_id
      end
      model_params = assign_model_params_parents(
        model_params, 
        [@submission.device_organization_id])
      @device_create_params = model_params

    when 'imaging_event'
      parents = []
      if @submission.biological_specimen_or_cultural_heritage_object == 'bso'
        if !@submission.biological_specimen_id.present?
          abort("Debug no biological specimen id #{@submission.biological_specimen_id}")
        end
        parents << @submission.biological_specimen_id
      elsif @submission.biological_specimen_or_cultural_heritage_object == 'cho'
        if !@submission.cultural_heritage_object_id.present?
          abort("Debug no cho id #{@submission.cultural_heritage_object_id}")
        end
        parents << @submission.cultural_heritage_object_id
      end
      if !@submission.device_id.present?
          abort("Debug no device id #{@submission.device_id}")
      end
      parents << @submission.device_id
      model_params = assign_model_params_parents(model_params, parents)
      @imaging_event_create_params = model_params

    when 'processing_event'
      parents = []
      if @submission.parent_media_not_in_ms.presence
        # absentee parent media
        parents = [@submission.imaging_event_id]
      else
        parents = @submission.parent_media_list.split(',')
      end
      model_params = assign_model_params_parents(model_params, parents)
      @processing_event_create_params = model_params

    when 'media'
      if @submission.raw_or_derived_media == 'raw' 
        parent = @submission.imaging_event_id
      elsif @submission.raw_or_derived_media == 'derived'
        parent = @submission.processing_event_id
      end
      model_params = assign_model_params_parents(model_params, parent)
      if addl_params[:uploaded_files].present?
        params.merge!({ uploaded_files: addl_params[:uploaded_files] })
      end
      @media_create_params = model_params

    # the below cases are only required for temp show page instance object creation
    when 'organization' 
      @organization_create_params = model_params
    when 'taxonomy'
      @taxonomy_create_params = model_params
    when 'device_organization'
      @device_organization_create_params = model_params
    end
  end

  def assign_model_params_parents(model_params, parents)
    parents = Array(parents)
    parent_attributes = {}
    i = 0
    abort("Debug empty parent error") if parents.empty?
    parents.each do |parent|
      abort("Debug parent error with #{parent}") if !parent.present?
      parent_attributes.merge!({ i.to_s => { "id" => parent, "_destroy" => "false" } })
      i += 1
    end
    model_params.merge!('work_parents_attributes' => parent_attributes)
  end

  # Utility functions

  def to_id(work)
    work + '_id'
  end

  def to_form(work)  
    work = ( work == 'device_organization' ? 'organization' : work )
    ('Hyrax::' + work.camelize + 'Form').constantize
  end

  def to_model(work)
    work = ( work == 'device_organization' ? 'organization' : work )
    work.camelize.constantize
  end

  ### END NEW METHODS ###

  def create
    reinstantiate_submission
    # todo: is there a need to separate raw and derived flow in two if and else?
    if params['biospec_search'].present?
      @docs = search_biospec
      @idigbio = search_idigbio
      @idigbio.reject!{|i| @docs.map{|d| d.idigbio_uuid}.flatten.compact.uniq.include?(i['uuid'])} unless (@docs.nil? || @idigbio.nil?)
      if (@docs.nil? || @docs.empty?) && (@idigbio.nil? || @idigbio.empty?)
        # if no search result, user might need to go back to initial step
        @submission.saved_step = ""
      else
        @submission.saved_step = "biospec_search"
      end
      store_submission
      render_and_save 'biospec'
    elsif params['biospec_select'].present?
      @submission.saved_step = "biospec_select"
      session[:submission][:biospec_id] = submission_params[:biospec_id]
      store_submission
      render_and_save 'device'
    elsif params['biospec_will_create'].present?
      # possibly need to store other flow data here
      @submission.saved_step = "biospec_will_create"
      store_submission
      render_and_save 'organization'
    elsif params['organization_select'].present? || params['no_organization'].present?
      if @submission.saved_step == "biospec_will_create"
        if params['organization_select'].present?
          session[:submission][:organization_id] = submission_params[:organization_id]
        end
        @submission.saved_step = "biospec_organization_select"
        render_and_save 'taxonomy'
      elsif @submission.saved_step == "cho_will_create"
        if params['organization_select'].present?
          session[:submission][:organization_id] = submission_params[:organization_id]
        end
        @submission.saved_step = "cho_organization_select"
        render_and_save 'cho_create'
      elsif @submission.saved_step == "device_will_create"
        if params['organization_select'].present?
          session[:submission][:device_organization_id] = submission_params[:organization_id]
        end
        @submission.saved_step = "device_organization_select"
        render_and_save 'device_create'
      else
        # should not end up here
      end
      store_submission
    elsif params['taxonomy_select'].present?
      @submission.saved_step = "biospec_taxonomy_select"
      render_and_save 'biospec_create'
    elsif params['device_select'].present?
      session[:submission][:device_id] = submission_params[:device_id]
      # get and store the modality, to be used for imaging event and media
      device = Device.where('id' => submission_params[:device_id]).first
      cookies.permanent[:modality_to_set] = device.modality.to_a
      @submission.saved_step = "device_select"
      store_submission
      render_and_save 'image_capture'
    elsif params['device_will_create'].present?
      # possibly need to store other flow data here
      @submission.saved_step = "device_will_create"
      store_submission
      render_and_save 'device_organization'
    elsif params['parent_media_select'].present?
      session[:submission][:parent_media_list] = submission_params[:parent_media_list]
      # get and store the modality, to be used for imaging event and media
      modality_to_set = []
      submission_params[:parent_media_list].split(',').each do |id|
        media = Media.where('id' => id).first
        # might need to handle multiple IEs if necessary later
        imaging_event = ImagingEvent.where('member_ids_ssim' => media.id)&.first.presence || nil
        modality_to_set += imaging_event.ie_modality.to_a if imaging_event.present?
      end
      cookies.permanent[:modality_to_set] = modality_to_set.join(',')
      store_submission
      render_and_save 'processing_event'
    elsif params['cho_search'].present?
      session[:submission][:cho_search_collection_code] = submission_params[:cho_search_collection_code]
      # todo: add the other 3 search fields here
      @submission.saved_step = "cho_search"
      store_submission
      @docs = search_cho
      render_and_save 'cho'
    elsif params['cho_select'].present?
      session[:submission][:cho_id] = submission_params[:cho_id]
      @submission.saved_step = "cho_select"
      store_submission
      render_and_save 'device'
    elsif params['cho_will_create'].present?
      # possibly need to store other flow data here
      @submission.saved_step = "cho_will_create"
      store_submission
      render_and_save 'organization'
    else
      finish_submission
    end
  end

  def render_and_save(pg)
    # save this page to render again if user reloads the page
    cookies.permanent[:current_render] = pg
    if (pg != 'new')
      cookies.delete :saved_clicks
    end
    render pg
  end

  def stage_biological_specimen
    reinstantiate_submission
    @submission.biospec_id = 'new'
    store_submission
    biospec_model_params = Hyrax::BiologicalSpecimenForm.model_attributes(params[:biological_specimen])
    session[:submission_biospec_create_params] = biospec_model_params
    render_and_save 'device'
  end

  def stage_biological_specimen_from_idigbio
    reinstantiate_submission
    @submission.biospec_id = 'new'
    # we also search for/stage the Taxonomy work here, since for IDigBio specimen creation we don't have separate steps
    idb_taxonomy_params = Morphosource::IDigBioSearchService.taxonomy_params_from_idigbio(params[:idigbio_id])
    existing_bso = Morphosource::PhysicalObjectsSearchService.call(BiologicalSpecimen, idb_taxonomy_params.clone)
    if (!existing_bso.nil?) && existing_bso.any?
      @submission.taxonomy_id = existing_bso.first.canonical_taxonomy.present? ? existing_bso.first.canonical_taxonomy.first : existing_bso.first.taxonomies.first.id
      @submission.canonical_taxonomy_id = @submission.taxonomy_id if existing_bso.first.canonical_taxonomy.present?
      store_submission
    else
      @submission.taxonomy_id = 'new'
      @submission.canonical_taxonomy_id = @submission.taxonomy_id
      store_submission
      taxonomy_model_params = Hyrax::TaxonomyForm.model_attributes(ActionController::Parameters.new(idb_taxonomy_params))
      session[:submission_taxonomy_create_params] = taxonomy_model_params
    end
    biospec_model_params = Hyrax::BiologicalSpecimenForm.model_attributes(ActionController::Parameters.new(Morphosource::IDigBioSearchService.biological_specimen_params_from_idigbio(params[:idigbio_id])))
    session[:submission_biospec_create_params] = biospec_model_params
    render_and_save 'device'
  end

  def stage_cho
    reinstantiate_submission
    @submission.cho_id = 'new'
    store_submission
    cho_model_params = Hyrax::CulturalHeritageObjectForm.model_attributes(params[:cultural_heritage_object])
    session[:submission_cho_create_params] = cho_model_params
    render_and_save 'device'
  end

  def stage_device
    reinstantiate_submission
    @submission.device_id = 'new'
    store_submission
    device_model_params = Hyrax::DeviceForm.model_attributes(params[:device])
    session[:submission_device_create_params] = device_model_params
    # store the modality, to be used for imaging event and media
    modality_to_set = []
    cookies.permanent[:modality_to_set] = device_model_params["modality"].join(',')
    render_and_save 'image_capture'
  end

  def stage_imaging_event
    reinstantiate_submission
    @submission.imaging_event_id = 'new'
    @submission.saved_step = 'imaging_event_staged'
    store_submission
    imaging_event_model_params = Hyrax::ImagingEventForm.model_attributes(params[:imaging_event])
    session[:submission_imaging_event_create_params] = imaging_event_model_params
    # need to go to proceesing event if coming from Derived media > Parents not in MorphoSource
    # parent_media_how_to_proceed
    if cookies[:will_create].present?
      if cookies[:will_create].include? 'processing_event'
        render_and_save 'processing_event'
      else
        render_and_save 'media'
      end
    else
      render_and_save 'media'
    end
  end

  def stage_organization
    reinstantiate_submission
    @submission.organization_id = 'new'
    store_submission
    organization_model_params = Hyrax::OrganizationForm.model_attributes(params[:organization])
    session[:submission_organization_create_params] = organization_model_params
    if @submission.saved_step == "biospec_will_create"
      render_and_save 'taxonomy'
    elsif @submission.saved_step == "cho_will_create"
      render_and_save 'cho_create'
    else
      #should not be here
    end
  end

  def stage_device_organization
    reinstantiate_submission
    @submission.device_organization_id = 'new'
    store_submission
    device_organization_model_params = Hyrax::OrganizationForm.model_attributes(params[:organization])
    session[:submission_device_organization_create_params] = device_organization_model_params
    render_and_save 'device_create'
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

  def stage_processing_event
    reinstantiate_submission
    @submission.processing_event_id = 'new'
    store_submission
    processing_event_model_params = Hyrax::ProcessingEventForm.model_attributes(params[:processing_event])
    session[:submission_processing_event_create_params] = processing_event_model_params
    render_and_save 'media'
  end

  def stage_taxonomy
    reinstantiate_submission
    @submission.taxonomy_id = 'new'
    store_submission
    taxonomy_model_params = Hyrax::TaxonomyForm.model_attributes(params[:taxonomy])
    session[:submission_taxonomy_create_params] = taxonomy_model_params
    render_and_save 'biospec_create'
  end

  def finish_submission
    reinstantiate_submission
    # The various object '_create_params' are defined as instance variables so they are available to the
    # placeholder 'show' page for debugging purposes.  If they are not needed for that, they can become local
    # variables in this method instead.
    @biospec_create_params = session[:submission_biospec_create_params]
    @cho_create_params = session[:submission_cho_create_params]
    @imaging_event_create_params = session[:submission_imaging_event_create_params]
    @organization_create_params = session[:submission_organization_create_params]
    @device_organization_create_params = session[:submission_device_organization_create_params]
    @device_create_params = session[:submission_device_create_params]
    @media_create_params = session[:submission_media_create_params]
    @processing_event_create_params = session[:submission_processing_event_create_params]
    @taxonomy_create_params = session[:submission_taxonomy_create_params]
    media_uploaded_files = session[:submission_media_uploaded_files]
    if @organization_create_params.present?
      @submission.organization_id = create_organization(@organization_create_params)
    end
    if @device_organization_create_params.present?
      @submission.device_organization_id = create_organization(@device_organization_create_params)
    end
    if @taxonomy_create_params.present?
      @submission.taxonomy_id = create_taxonomy(@taxonomy_create_params)
      if @submission.canonical_taxonomy_id == 'new'
        @submission.canonical_taxonomy_id = @submission.taxonomy_id
      end
    end
    if @biospec_create_params.present?
      @submission.biospec_id = create_biological_specimen(@biospec_create_params)
    end
    if @cho_create_params.present?
      @submission.cho_id = create_cho(@cho_create_params)
    end
    if @device_create_params.present?
      @submission.device_id = create_device(@device_create_params)
    end
    if @imaging_event_create_params.present?
      @submission.imaging_event_id = create_imaging_event(@imaging_event_create_params)
    end
    if @processing_event_create_params.present?
      @submission.processing_event_id = create_processing_event(@processing_event_create_params)
    end
    if @media_create_params.present?
      @submission.media_id = create_media(@media_create_params, media_uploaded_files)
    end
    clear_session_submission_settings
    render 'show'
    #redirect_to '/concern/media/' + @submission.media_id
  end

  def create_biological_specimen(params)
    parent_attributes = {}
    if @submission.organization_id.present?
      parent_attributes.merge!({ '0' => { "id" => @submission.organization_id, "_destroy" => "false" } })
    end
    if @submission.taxonomy_id.present?
      parent_attributes.merge!({ '1' => { "id" => @submission.taxonomy_id, "_destroy" => "false" } })
    end
    if @submission.canonical_taxonomy_id.present?
      params.merge!('canonical_taxonomy' => [@submission.canonical_taxonomy_id])
    end
    unless parent_attributes.empty?
      params.merge!('work_parents_attributes' => parent_attributes)
    end
    create_work(BiologicalSpecimen, params)
  end

  def create_cho(params)
    parent_attributes = {}
    if @submission.organization_id.present?
      parent_attributes.merge!({ '0' => { "id" => @submission.organization_id, "_destroy" => "false" } })
    end
    unless parent_attributes.empty?
      params.merge!('work_parents_attributes' => parent_attributes)
    end
    create_work(CulturalHeritageObject, params)
  end

  def create_device(params)
    parent_attributes = {}
    if @submission.present?
      if @submission.device_organization_id.present?
        if @submission.device_organization_id == 'new_organization_id_to_be_created'
          # user has selected the new organization which is waiting to be created
          # at this point this new organization has been created.  set the id to the new organization id
          @submission.device_organization_id = @submission.organization_id
        end
        parent_attributes.merge!({ '0' => { "id" => @submission.device_organization_id, "_destroy" => "false" } })
      end
    end
    unless parent_attributes.empty?
      params.merge!('work_parents_attributes' => parent_attributes)
    end
    create_work(Device, params)
  end

  def create_imaging_event(params)
    parent_attributes = {}
    if @submission.biospec_id.present?
      parent_attributes.merge!({ '0' => { "id" => @submission.biospec_id, "_destroy" => "false" } })
    end
    if @submission.cho_id.present?
      parent_attributes.merge!({ '1' => { "id" => @submission.cho_id, "_destroy" => "false" } })
    end
    if @submission.device_id.present?
      parent_attributes.merge!({ '2' => { "id" => @submission.device_id, "_destroy" => "false" } })
    end
    unless parent_attributes.empty?
      params.merge!('work_parents_attributes' => parent_attributes)
    end
    create_work(ImagingEvent, params)
  end

  def create_processing_event(params)
    parent_attributes = {}
    idx = 0
    if cookies[:absentee_parent].present?
      # when creating a media with absentee parent
      # the relationship should be PO > IE > PE > media
      parent_attributes.merge!({ '0' => { "id" => @submission.imaging_event_id, "_destroy" => "false" } })
      idx += 1
    end
    if @submission.parent_media_list.present?
      @submission.parent_media_list.split(',').each do |this_id|
        if this_id != ''
          parent_attributes.merge!({ idx.to_s => { "id" => this_id.to_s, "_destroy" => "false" } })
          idx += 1
        end
      end
    end
    unless parent_attributes.empty?
      params.merge!('work_parents_attributes' => parent_attributes)
    end
    create_work(ProcessingEvent, params)
  end

  def create_taxonomy(params)
    create_work(Taxonomy, params)
  end

  def create_organization(params)
    create_work(Organization, params)
  end

  def create_media(params, uploaded_files)
    parent_attributes = {}
    if @submission.imaging_event_id.present?
      cookies.permanent[:imaging_event_id] = @submission.imaging_event_id
      if cookies[:absentee_parent].present?
        # when creating a media with absentee parent
        # do not add IE as parent, since the relationship should be PO > IE > PE > media
      else
        parent_attributes.merge!({ '0' => { "id" => @submission.imaging_event_id, "_destroy" => "false" } })
      end
    end
    if @submission.processing_event_id.present?
      parent_attributes.merge!({ '1' => { "id" => @submission.processing_event_id, "_destroy" => "false" } })
    end
    unless parent_attributes.empty?
      params.merge!('work_parents_attributes' => parent_attributes)
    end
    if uploaded_files.present?
      params.merge!({ uploaded_files: uploaded_files })
    end
    create_work(Media, @media_create_params)
  end

  def new_organization
    @submission = Submission.new(session[:submission])
    render 'new_organization'
  end

  def new_organization_submit
    # this method is expected to be called from a form in modal, or an ajax post
    begin
      organization_model_params = Hyrax::OrganizationForm.model_attributes(params[:organization])
      new_organization_id = create_organization(organization_model_params)
    rescue
      new_organization_id = nil
    end

    if new_organization_id.present?
      status = 'OK'
      message = 'New organization created'
      new_organization = Organization.where('id' => new_organization_id).first
      new_work = {
        :id => new_organization_id,
        :title => new_organization.title.first,
        :institution_code => new_organization.institution_code.first,
        :institution_name => new_organization.institution_name.first,
        :collection_code => new_organization.collection_code.first,
        :description => new_organization.description.first,
        :address => new_organization.address.first,
        :city => new_organization.city.first,
        :state_province => new_organization.state_province.first,
        :country => new_organization.country.first
      }
    else
      status = 'FAIL'
      message = 'There is a problem creating the organization.'
      new_work = {}
    end
    response_object = {
      :work => new_work,
      :status => status,
      :message => message
    }
    render :json => response_object
  end

  def new_taxonomy
    @submission = Submission.new(session[:submission])
    render 'new_taxonomy'
  end

  def new_taxonomy_submit
    # this method is expected to be called from a form in modal, or an ajax post
    begin
      taxonomy_model_params = Hyrax::TaxonomyForm.model_attributes(params[:taxonomy])
      new_taxonomy_id = create_taxonomy(taxonomy_model_params)
    rescue
      new_taxonomy_id = nil
    end

    if new_taxonomy_id.present?
      status = 'OK'
      message = 'New Taxonomy created'
      new_taxonomy = Taxonomy.where('id' => new_taxonomy_id).first
      new_work = {
        :id => new_taxonomy_id,
        :title => new_taxonomy.title.first,
        :taxonomy_domain => new_taxonomy.taxonomy_domain.first,
        :taxonomy_kingdom => new_taxonomy.taxonomy_kingdom.first,
        :taxonomy_phylum => new_taxonomy.taxonomy_phylum.first,
        :taxonomy_superclass => new_taxonomy.taxonomy_superclass.first,
        :taxonomy_class => new_taxonomy.taxonomy_class.first,
        :taxonomy_subclass => new_taxonomy.taxonomy_subclass.first,
        :taxonomy_superorder => new_taxonomy.taxonomy_superorder.first,
        :taxonomy_order => new_taxonomy.taxonomy_order.first,
        :taxonomy_suborder => new_taxonomy.taxonomy_suborder.first,
        :taxonomy_superfamily => new_taxonomy.taxonomy_superfamily.first,
        :taxonomy_family => new_taxonomy.taxonomy_family.first,
        :taxonomy_subfamily => new_taxonomy.taxonomy_subfamily.first,
        :taxonomy_tribe => new_taxonomy.taxonomy_tribe.first,
        :taxonomy_genus => new_taxonomy.taxonomy_genus.first,
        :taxonomy_subgenus => new_taxonomy.taxonomy_subgenus.first,
        :taxonomy_species => new_taxonomy.taxonomy_species.first,
        :taxonomy_subspecies => new_taxonomy.taxonomy_subspecies.first,
        :depositor => new_taxonomy.depositor
      }
    else
      status = 'FAIL'
      message = 'There is a problem creating the taxonomy.'
      new_work = {}
    end
    response_object = {
      :work => new_work,
      :status => status,
      :message => message
    }
    render :json => response_object
  end

  def new_device_submit
    # this method is expected to be called from a form in modal, or an ajax post
    begin
      device_model_params = Hyrax::DeviceForm.model_attributes(params[:device])
      new_device_id = create_device(device_model_params)
    rescue Exception => ex
      new_device_id = nil
      exception_message = "Exception: #{ex.class}, #{ex.message}"
    end
    if new_device_id.present?
      status = 'OK'
      message = 'New device created'
      new_device = Device.where('id' => new_device_id).first
      new_work = {
        :id => new_device_id,
        :title => new_device.title.first,
        :creator => new_device.creator.first,
        :modality => new_device.modality.first,
        :description => new_device.description.first,
        :organization_institution => organization_institution(new_device_id)
      }
    else
      status = 'FAIL'
      message = 'There is a problem creating the device. ' + exception_message
      new_work = {}
    end
    response_object = {
      :work => new_work,
      :status => status,
      :message => message
    }
    render :json => response_object
  end

  def new_processing_event_submit
    # this method is expected to be called from a form in modal, or an ajax post
    begin
      processing_event_model_params = Hyrax::ProcessingEventForm.model_attributes(params[:processing_event])
      new_processing_event_id = create_work(ProcessingEvent, processing_event_model_params)
    rescue Exception => ex
      new_processing_event_id = nil
      exception_message = "Exception: #{ex.class}, #{ex.message}"
    end
    if new_processing_event_id.present?
      if params['child_media_id'].present?
        # update the child media (by setting this PE as a parent)
        # child < PE < parent
        child_media_id = params['child_media_id']
        child_media = Media.find(child_media_id)
        processing_event = ::ActiveFedora::Base.find(new_processing_event_id)
        processing_event.ordered_members << child_media
        processing_event.save!
        child_media.save!
        new_processing_event_updates(child_media)
      end
      status = 'OK'
      message = 'New processing_event created'
      new_processing_event = ProcessingEvent.where('id' => new_processing_event_id).first
      new_work = {
        :id => new_processing_event_id,
        :title => new_processing_event.title.first
      }
    else
      status = 'FAIL'
      message = 'There is a problem creating the processing_event. ' + exception_message
      new_work = {}
    end
    response_object = {
      :work => new_work,
      :status => status,
      :message => message
    }
    render :json => response_object
  end

  private

  def clear_session_submission_settings
    session[:submission] = nil
  end

  def create_work(model, form_params)
    curation_concern = model.new
    attributes_for_actor = form_params
    if model == Media
      set_visibilities(attributes_for_actor)
    else
      attributes_for_actor.merge!({ visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC })
    end
    env = Hyrax::Actors::Environment.new(curation_concern, current_ability, attributes_for_actor)
    Hyrax::CurationConcern.actor.create(env)
    curation_concern.id
  end

  def set_visibilities(attributes_for_actor)
    selected = attributes_for_actor["visibility"]
    public = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    private = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
    embargo = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO
    lease = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_LEASE

    visibilities = {
      public =>
        { "work_visibility" => public,
          "file_visibility" => "",
          "file_accessibility" => "open"},
      "restricted_download" =>
        { "work_visibility" => public,
          "file_visibility" => "",
          "file_accessibility" => "restricted_download"},
      "preview" =>
        { "work_visibility" => public,
          "file_visibility" => "",
          "file_accessibility" => "preview_only"},
      "hidden" =>
        { "work_visibility" => public,
          "file_visibility" => "restricted",
          "file_accessibility" => "hidden"},
      private =>
        { "work_visibility" => private,
          "file_visibility" => "",
          "file_accessibility" => "private"},
      embargo =>
        { "work_visibility" => embargo,
          "file_visibility" => "",
          "file_accessibility" => ""},
      lease =>
        { "work_visibility" => lease,
          "file_visibility" => "",
          "file_accessibility" => ""} }

    attributes_for_actor["visibility"] = visibilities[selected]["work_visibility"]
    attributes_for_actor["fileset_visibility"] = [visibilities[selected]["file_visibility"]]
    attributes_for_actor["fileset_accessibility"] = [visibilities[selected]["file_accessibility"]]
  end

  def instantiate_work_forms
    @biological_specimen_form = Hyrax::WorkFormService.build(BiologicalSpecimen.new, current_ability, self)
    @cho_form = Hyrax::WorkFormService.build(CulturalHeritageObject.new, current_ability, self)
    @device_form = Hyrax::WorkFormService.build(Device.new, current_ability, self)
    @imaging_event_form = Hyrax::WorkFormService.build(ImagingEvent.new, current_ability, self)
    @processing_event_form = Hyrax::WorkFormService.build(ProcessingEvent.new, current_ability, self)
    @organization_form = Hyrax::WorkFormService.build(Organization.new, current_ability, self)
    @media_form = Hyrax::WorkFormService.build(Media.new, current_ability, self)
    @taxonomy_form = Hyrax::WorkFormService.build(Taxonomy.new, current_ability, self)
  end

  def save_params_to_session
    session[:submission].deep_merge!(submission_params) if params[:submission]
  end

  def reinstantiate_submission
    save_params_to_session
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

  def search_idigbio
    search_params = {}
    biospec_search_params = submission_params.select{ |k,v| k.match(/^biospec_search_/) }.select{ |k,v| v.present? }
    biospec_search_params.each do |k,v|
      search_params[k.sub('biospec_search_', '')] = v
    end
    Morphosource::IDigBioSearchService.call(search_params)
  end

  def search_cho
    search_params = {}
    cho_search_params = submission_params.select{ |k,v| k.match(/^cultural_heritage_object_search_/) }.select{ |k,v| v.present? }
    cho_search_params.each do |k,v|
      search_params[k.sub('cultural_heritage_object_search_', '')] = v
    end
    Morphosource::PhysicalObjectsSearchService.call(CulturalHeritageObject, search_params)
  end

  def store_submission
    session[:submission] = { biospec_id: @submission.biospec_id,
                              cho_id: @submission.cho_id,
                              biospec_or_cho: @submission.biospec_or_cho,
                              device_id: @submission.device_id,
                              organization_id: @submission.organization_id,
                              device_organization_id: @submission.device_organization_id,
                              raw_or_derived_media: @submission.raw_or_derived_media,
                              parent_media_how_to_proceed: @submission.parent_media_how_to_proceed,
                              parent_media_list: @submission.parent_media_list,
                              taxonomy_id: @submission.taxonomy_id,
                              canonical_taxonomy_id: @submission.canonical_taxonomy_id,
                              cho_search_collection_code: @submission.cho_search_collection_code,
                              saved_step: @submission.saved_step
      }
    if @submission.saved_step.present?
      cookies.permanent[:saved_step] = @submission.saved_step
    end
  end

  def coerce_strings_to_booleans(params)
    params.transform_values {|p| (p == 'true' || p == 'false') ? ActiveModel::Type::Boolean.new.cast(p) : p  } 
  end

  def submission_params
    coerce_strings_to_booleans(
      params
        .fetch(:submission, {})
        .permit( 
                { :form_data => {} },
                { :work_data => {} },
                :saved_step,
                :submission_media_type,
                :submission_modality,
                :raw_or_derived_media,
                :parent_media_list,
                :parent_media_not_in_ms,
                :biological_specimen_or_cultural_heritage_object,
                :po_saved_view,
                :biological_specimen_id,
                :idigbio_id,
                :will_create_biological_specimen,
                :cultural_heritage_object_id,
                :will_create_cultural_heritage_object,
                :organization_id,
                :no_organization,
                :will_create_organization,
                :taxonomy_id,
                :canonical_taxonomy_id,
                :will_create_taxonomy,
                :device_id,
                :will_create_device,
                :device_organization_id,
                :device_no_organization,
                :will_create_device_organization,
                :imaging_event_id,
                :processing_event_id,
                :media_id,
                :is_start_over,
                :parent_media_search,
                :biospec_search_catalog_number,
                :biospec_search_collection_code,
                :biospec_search_institution_code,
                :biospec_search_occurrence_id,
                :biospec_search_taxonomy_genus,
                :biospec_search_taxonomy_species,
                :cultural_heritage_object_search_catalog_number,
                :cultural_heritage_object_search_collection_code,
                :cultural_heritage_object_search_institution_code,
                :cultural_heritage_object_search_occurrence_id,
                :cultural_heritage_object_search_short_title,
                :taxonomy_search
        )
    )
  end

end
