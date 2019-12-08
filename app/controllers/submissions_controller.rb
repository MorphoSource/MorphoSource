class SubmissionsController < ApplicationController
  # Adds Hyrax behaviors to the controller.
  include Hyrax::WorksControllerBehavior

  load_and_authorize_resource

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
    # todo: remove the below few lines later, since the clear_session_submission_settings has been moved to clean start block.
    # clear session when user request to start all over
    if cookies[:ms_submission_start_over].present?
        clear_session_submission_settings
    end
    if session[:submission].present?
      # Continue where the user has left off
      # last_render saves the page that needs to be rendered if the user reload the page, or
      # come back to when the user has left off later
      # saved_step stores the last page usually. it's needed when, for example, the user needs to go back
      # to new device after creating / selecting an organization.
      # if needed, read the var from session instead: session[:submission]['saved_step']
      saved_step = cookies[:saved_step]
      last_render = cookies[:last_render]
      if last_render.present?
        # certain pages require getting back the search result before rendering
        if last_render == 'biospec'
          @docs = search_biospec
        elsif last_render == 'cho'
          @docs = search_cho
        end
        render last_render
      end
    else
      # clean start
      session[:submission] ||= {}
      @submission = Submission.new(session[:submission])
    end
  end

  def create
    reinstantiate_submission
    # todo: is there a need to separate raw and derived flow in two if and else?
    if params['biospec_search'].present?
      @docs = search_biospec
      if @docs.nil? || @docs.empty?
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
    cookies.permanent[:last_render] = pg
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
    else
      # need to get device org id if passed in

        # parent_attributes.merge!({ '0' => { "id" => @submission.device_organization_id, "_destroy" => "false" } })

    end
    byebug
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
      



      
      # todo: will need to get device org later and add it to device_model_params?
      

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
        :description => new_device.description.first
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

  private

  def clear_session_submission_settings
    session[:submission] = nil
    session[:submission_biospec_create_params] = nil
    session[:submission_cho_create_params] = nil
    session[:submission_device_create_params] = nil
    session[:submission_imaging_event_create_params] = nil
    session[:submission_processing_event_create_params] = nil
    session[:submission_organization_create_params] = nil
    session[:submission_device_organization_create_params] = nil
    session[:submission_media_create_params] = nil
    session[:submission_taxonomy_create_params] = nil
    cookies.delete :ms_submission_start_over
    cookies.delete :saved_step
    cookies.delete :last_render
    cookies.delete :saved_clicks
    cookies.delete :will_create
    cookies.delete :absentee_parent
    cookies.delete :modality_to_set
  end

  def create_work(model, form_params)
    curation_concern = model.new
    attributes_for_actor = form_params
    unless model == Media
      attributes_for_actor.merge!({ visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC })
    end
    if model == Media
      set_visibilities(attributes_for_actor)
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

  def search_cho
    search_params = {}
    cho_search_params = submission_params.select{ |k,v| k.match(/^cho_search_/) }.select{ |k,v| v.present? }
    cho_search_params.each do |k,v|
      search_params[k.sub('cho_search_', '')] = v
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
                              cho_search_collection_code: @submission.cho_search_collection_code,
                              saved_step: @submission.saved_step
      }
    if @submission.saved_step.present?
      cookies.permanent[:saved_step] = @submission.saved_step
    end
  end

  def submission_params
    params.fetch(:submission, {}).permit( :biospec_id,
                                          :biospec_or_cho,
                                          :biospec_search_catalog_number,
                                          :biospec_search_collection_code,
                                          :biospec_search_institution_code,
                                          :biospec_search_occurrence_id,
                                          :biospec_search_taxonomy_genus,
                                          :biospec_search_taxonomy_species,
                                          :cho_id,
                                          :cho_search_catalog_number,
                                          :cho_search_collection_code,
                                          :cho_search_institution_code,
                                          :cho_search_occurrence_id,
                                          :device_id,
                                          :imaging_event_id,
                                          :organization_id,
                                          :device_organization_id,
                                          :media_id,
                                          :processing_event_id,
                                          :raw_or_derived_media,
                                          :parent_media_how_to_proceed,
                                          :parent_media_search,
                                          :parent_media_list,
                                          :taxonomy_search,
                                          :taxonomy_id
      )
  end

end
