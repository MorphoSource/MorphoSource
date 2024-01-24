require 'net/http'
require 'uri'
require 'json'

class SubmissionsController < ApplicationController
  # Adds Hyrax behaviors to the controller.
  include Hyrax::WorksControllerBehavior
  include MorphosourceHelper
  include Morphosource::PermissionsHelper
  include Morphosource::LinkedTeams::LinkedTeamsManagement
  include Morphosource::CustomThumbnails
  include SubmissionsControllerAjaxBehavior

  load_and_authorize_resource except: [:search_po_ajax, :search_taxonomy_ajax, :validate_remote_file_ajax,
    :save_data, :organization_for_recordset, :organization_default_media_fields,
    :new_taxonomy_submit, :new_processing_event_submit]

  before_action :instantiate_work_forms

  class_attribute :device_organizations_search_builder_class
  self.device_organizations_search_builder_class = Morphosource::Catalog::Organizations::DeviceOrganizationsCatalogSearchBuilder

  class_attribute :object_organizations_search_builder_class
  self.object_organizations_search_builder_class = Morphosource::Catalog::Organizations::ObjectOrganizationsCatalogSearchBuilder

  # return all possible organization records for organization search
  configure_blacklight do |config|
    config.max_per_page = 1000000
  end

  # override the layout from WorksControllerBehavior
  def decide_layout
    layout = 'submission'
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

    @device_organizations = repository.search(device_organizations_search_builder.query)["response"]["docs"]
    @object_organizations = repository.search(object_organizations_search_builder.query)["response"]["docs"]

    @device_organizations_select2 = @device_organizations.map do |o|
      {
        id: o['id'],
        text: "#{[o['institution_name_tesim']&.first, o['title_tesim']&.first].compact.join(', ')} (#{o['institution_code_tesim']&.join('/')}:#{o['collection_code_tesim']&.join('/')})",
        organization_type: o['organization_type_tesim']&.first,
        institution_name: o['institution_name_tesim']&.first,
        title: o['title_tesim']&.first,
        institution_code: o['institution_code_tesim']&.join(', '),
        collection_code: o['collection_code_tesim']&.join(', '),
        related_url: o['related_url_tesim']&.first,
        address: o['address_tesim']&.first,
        city: o['city_tesim']&.first,
        state_province: o['state_province_tesim']&.first,
        country: o['country_tesim']&.first,
        postal_code: o['postal_code_tesim']&.first,
        description: o['description_tesim']&.first,
        contact_person: o['contact_person_tesim']&.first,
        devices: o['member_ids_ssim'],
        data_manager: o['data_manager_tesim']&.first
      }
    end

    @object_organizations_select2 = @object_organizations.map do |o|
      {
        id: o['id'],
        text: "#{[o['institution_name_tesim']&.first, o['title_tesim']&.first].compact.join(', ')} (#{o['institution_code_tesim']&.join('/')}:#{o['collection_code_tesim']&.join('/')})",
        organization_type: o['organization_type_tesim']&.first,
        institution_name: o['institution_name_tesim']&.first,
        title: o['title_tesim']&.first,
        institution_code: o['institution_code_tesim']&.join(', '),
        collection_code: o['collection_code_tesim']&.join(', '),
        related_url: o['related_url_tesim']&.first,
        address: o['address_tesim']&.first,
        city: o['city_tesim']&.first,
        state_province: o['state_province_tesim']&.first,
        country: o['country_tesim']&.first,
        postal_code: o['postal_code_tesim']&.first,
        description: o['description_tesim']&.first,
        contact_person: o['contact_person_tesim']&.first,
        devices: o['member_ids_ssim'],
        data_manager: o['data_manager_tesim']&.first
      }
    end

    if Hyrax.config.null_organization_id.present? && Organization.exists?(Hyrax.config.null_organization_id)
      o = Organization.find(Hyrax.config.null_organization_id)
      @null_organization = {
        id: o.id,
        text: "#{[o.institution_name&.first, o.title&.first].compact.join(', ')} (#{o.institution_code&.join('/')}:#{o.collection_code&.join('/')})",
        organization_type: o.organization_type&.first,
        institution_name: o.institution_name&.first,
        title: o.title&.first,
        institution_code: o.institution_code&.join(', '),
        collection_code: o.collection_code&.join(', '),
        related_url: o.related_url&.first,
        address: o.address&.first,
        city: o.city&.first,
        state_province: o.state_province&.first,
        country: o.country&.first,
        postal_code: o.postal_code&.first,
        description: o.description&.first,
        contact_person: o.contact_person&.first,
        devices: o.member_ids
      }
    else
      @null_organization = {}
    end

    @devices = Device.all_solr
    @devices_with_ids = @devices.map do |d|
      [d['id'], {
        id: d['id'],
        text: [d['creator_tesim']&.first, d['title_tesim']&.first].compact.join(' '),
        title: d['title_tesim']&.first,
        creator: d['creator_tesim']&.first,
        modality: d['modality_tesim']&.join(','),
        description: d['description_tesim']&.first
      }]
    end.to_h
    if !current_user.admin?
      @devices_with_ids.delete(Hyrax.config.unknown_ct_scanner)
    end

    if params[:collection]
      begin
        @collection = Collection.find(params[:collection])
        @submission.collection_id = @collection.id
        @submission.collection_name = @collection.title.first
      rescue
      end
    end
  end

  def search_po_ajax
    @po_type = submission_params[:biological_specimen_or_cultural_heritage_object]
    if @po_type == 'bso'
      @docs = search_biospec
      @docs_idigbio_uuids = @docs.map{|d| d.idigbio_uuid}.flatten.compact.uniq
      @idigbio = search_idigbio
    elsif @po_type == 'cho'
      @docs = search_cho
      @idigbio = {}
    end
    respond_to do |format|
      format.js
    end
  end

  def search_taxonomy_ajax
    @submission = Submission.new()
    search_term = params[:q]
    gbif_taxa = Morphosource::GbifSearchService.call({ 'name' => search_term })
    ms_taxa = Qa::Authorities::FindTaxonomies.new().search_submission(search_term, self)

    gbif_ms_ids = gbif_taxa.map { |t| t[:ms] }
    ms_taxa = ms_taxa.reject { |t| gbif_ms_ids.include? t[:id] }

    render :json => gbif_taxa + ms_taxa
  end

  def validate_remote_file_ajax
    if !current_user.can_submit_remote_file?(params[:u], params[:o])
      status = "error"
      message = "The path is invalid or not allowed.  Please make sure you have the permissions and the domain is allowed."
      http_code = ""
      resp_file_ext = ""
    else
      rf = MorphosourceHelper::RemoteFileInfo.new(params[:u])
      status = rf.status
      http_code = rf.http_code
      message = rf.message
      resp_file_ext = rf.file_ext
    end
    response_object = {
      status: status,
      http_code: http_code,
      message: message,
      resp_file_ext: resp_file_ext
    }
    render :json => response_object
  end

  def organization_for_recordset
    recordset_id = params[:recordset_id]

    if Organization.where(recordset_id: recordset_id).count == 1
      organization = Organization.where(recordset_id: recordset_id).first
    else
      organization = nil
    end

    if organization.present?
      status = 'OK'
      organization_found = true
      organization_id = organization.id
    else
      status = 'FAIL'
      organization_found = false
      organization_id = nil
    end

    response_object = {
      status: status,
      organization_found: organization_found,
      organization_id: organization_id
    }
    render :json => response_object
  end

  def organization_default_media_fields
    organization = find_ancestor_organization
    if organization.present?
      status = 'OK'
      default_fields = default_media_permissions(organization)
      message = 'Organization default permission settings retrieved'
      message << ', but no default fields present' if !default_fields.present?
      organization_alert_message = alert(organization)
      organization_title = organization.title
      organization_id = organization.id
      organization_team_id = organization.team&.id
      organization_team_can_submit_remote_files = organization.team&.can_submit_remote_files
      organization_permissions_mode = organization.permissions_enforcement_mode&.first || 'Recommend'
      organization_data_manager = organization.data_manager&.first
      organization_data_manager_name = User.find_by_user_key(organization_data_manager)&.name_or_email
    else
      status = 'FAIL'
      message = 'Organization does not exist'
      default_fields = {}
      organization_alert_message = ''
      organization_title = ''
      organization_id = nil
      organization_team_id = nil
      organization_team_can_submit_remote_files = nil
      organization_permissions_mode = nil
      organization_data_manager = nil
      organization_data_manager_name = nil
    end
    response_object = {
      status: status,
      message: message,
      default_fields: default_fields,
      organization_alert_message: organization_alert_message,
      organization_title: organization_title,
      organization_id: organization_id,
      organization_team_id: organization_team_id,
      organization_permissions_mode: organization_permissions_mode,
      organization_data_manager: organization_data_manager,
      organization_data_manager_name: organization_data_manager_name,
      org_team_can_submit_remote_files: organization_team_can_submit_remote_files
    }
    render :json => response_object
  end

  def save_data
    save_params_to_session
  end

  def create
    clear_session_submission_settings
    reinstantiate_submission

    @submission.taxonomy_params_array = []
    @submission.taxonomy_id_array = @submission.taxonomy_id_array.present? ? @submission.taxonomy_id_array.split(',') : []
    @submission.taxonomy_gbif_key_array = @submission.taxonomy_gbif_key_array.present? ? @submission.taxonomy_gbif_key_array.split(',') : []

    if @submission.idigbio_id.present?
      # What taxonomy does this specimen have? Do they exist in MS2 or create them?
      idb_taxonomy_param_sets = Morphosource::IDigBioSearchService.taxonomy_param_sets_from_idigbio(@submission.idigbio_id)
      provider_params = idb_taxonomy_param_sets[:provider]
      gbif_params = idb_taxonomy_param_sets[:gbif]

      if provider_params.present?
        prov = Morphosource::TaxonomySearchService.match_taxonomies_strict(provider_params)
        if prov.present?
          # Exists, link as canonical
          @submission.canonical_taxonomy_id = prov.first.id
          @submission.taxonomy_id_array << prov.first.id unless @submission.taxonomy_id_array.include?(prov.first.id)
        else
          # Is new, must create
          provider_params[:canonical] = true # to be hooked in later to set canonical taxonomy ID
          @submission.taxonomy_params_array << ActionController::Parameters.new(provider_params)
        end
      end

      if gbif_params.present?
        gbif = Morphosource::TaxonomySearchService.call({ gbif_key: gbif_params['gbif_key'] })
        if gbif.present?
          @submission.taxonomy_id_array << gbif.first.id unless @submission.taxonomy_id_array.include?(gbif.first.id)
        else
          @submission.taxonomy_params_array << ActionController::Parameters.new(gbif_params)
        end
      end

      # Get specimen params from iDigBio
      params[:biological_specimen] = ActionController::Parameters.new(
        Morphosource::IDigBioSearchService.biological_specimen_params_from_idigbio(
          @submission.idigbio_id))
    else
      # Manual physical object creation, may need to do extra steps
      if @submission.will_create_taxonomy
        @submission.taxonomy_params_array << params[:taxonomy]
      end

      @submission.taxonomy_gbif_key_array.each do |gbif_key| # this may be empty
        gbif = Morphosource::TaxonomySearchService.call({ gbif_key: gbif_key.to_s })
        if gbif.present?
          @submission.taxonomy_id_array << gbif.first.id unless @submission.taxonomy_id_array.include?(gbif.first.id)
        else
          @submission.taxonomy_params_array << ActionController::Parameters.new(
            Morphosource::GbifSearchService.taxonomy_params_from_gbif(gbif_key))
        end
      end

    end

    # Is the media associated with an existing parent? If so, find organization ID
    # TODO refactor this, possibly put in JS defaultMediaFields code??
    if (
      @submission.parent_media_list.present? &&
      Media.exists?(@submission.parent_media_list&.split(',')&.first) &&
      !@submission.organization_id.present?
    )
      parent_media = Media.find(@submission.parent_media_list&.split(',')&.first)
      @submission.organization_id = parent_media&.organizations&.first&.id
    end

    works.each do |work|
      if work == 'taxonomy' && @submission.taxonomy_params_array.present?
        @submission.taxonomy_params_array.each do |taxon_params|
          new_taxon_id = prepare_and_create_work('taxonomy', { 'taxonomy' => taxon_params })[0]
          @submission.taxonomy_id_array << new_taxon_id
          @submission.canonical_taxonomy_id = new_taxon_id if taxon_params[:canonical]
        end
      else
        #puts("Creating #{work} if necessary")
        create_work_if_needed(work, params)
      end
    end
    reindex_catalog_works

    redirect_to main_app.hyrax_media_path(@submission.media_id, locale: 'en'), notice: flash_message, alert: alert_message if @submission.media_id
  end

  def flash_message
    "New media has been added. "
  end

  def alert_message
    I18n.t("morphosource.media.alert.browse_everything") if ( params[:selected_files].present? && params[:uploaded_files].present? )
  end

  def new_taxonomy_create(params)
    # this method is expected to be called from the backend
    begin
      prepare_and_create_work('taxonomy', { 'taxonomy' => params[:taxonomy] })[0]
    rescue
      nil
    end
  end

  private

  def works
    ['taxonomy', 'biological_specimen', 'cultural_heritage_object', 'imaging_event', 'processing_event', 'media']
  end

  def create_work_if_needed(work, params)
    if !@submission.public_send(to_id(work)).present? && params[work]
      # puts("Creating #{work}")
      new_work_id, new_work = prepare_and_create_work(work, params)
      @submission.public_send(to_id(work) + '=', new_work_id)
      create_attachment_if_needed(work, new_work_id) if ['imaging_event', 'processing_event', 'media'].include?(work)
      # Morphosource::CustomThumbnails
      if work == 'media'
        create_thumbnail
        set_new_fund_code if @submission.fund_code.present?
        create_organization_transfer_request(new_work) if ( organization_media_transfer == :immediate )
      end
    end
  end

  def prepare_and_create_work(work, params)
    model_params = create_model_params(work, params)
    attributes_for_actor = create_attributes_for_actor(to_model(work), model_params)
    create_work(to_model(work), attributes_for_actor)
  end

  def create_model_params(work, params)
    model_params = to_form(work).model_attributes(params[work])
    if work == 'media'
      addl_params = { uploaded_files: params[:uploaded_files] }
      addl_params[:selected_files] = params[:selected_files] if params[:selected_files].present?
      addl_params[:collection_id] = params[:collection_id] if params[:collection_id].present?
      addl_params[:organization_transfer_on_publish] = true if ( organization_media_transfer == :publication )
      finalize_model_params(work, model_params, addl_params)
    elsif work == 'imaging_event'
      addl_params = { device_id: [@submission.device_id] }
      finalize_model_params(work, model_params, addl_params)
    elsif work == 'biological_specimen' || work == 'cultural_heritage_object'
      addl_params = { organization_id: [@submission.organization_id] }
      finalize_model_params(work, model_params, addl_params)
    else
      finalize_model_params(work, model_params)
    end

  end

  def finalize_model_params(work, model_params, addl_params={})
    case work
    when 'biological_specimen'
      model_params.merge!(addl_params)
      if @submission.taxonomy_id_array.present?
        model_params.merge!(taxonomy_id: Array(@submission.taxonomy_id_array))
      end
      if @submission.canonical_taxonomy_id.present?
        model_params.merge!(canonical_taxonomy: [@submission.canonical_taxonomy_id])
      end
      @biospec_create_params = model_params

    when 'cultural_heritage_object'
      model_params.merge!(addl_params)
      @cho_create_params = model_params

    when 'device'
      if @submission.device_organization_id == 'submission_organization'
        @submission.device_organization_id = @submission.organization_id
      end
      if @submission.device_organization_id.present?
        model_params = assign_model_params_parents(
          model_params,
          [@submission.device_organization_id]
        )
      end
      @device_create_params = model_params

    when 'imaging_event'

      if @submission.biological_specimen_or_cultural_heritage_object == 'bso'
        if !@submission.biological_specimen_id.present?
          raise StandardError.new "Debug no biological specimen id #{@submission.biological_specimen_id}"
        end
        addl_params.merge!({ physical_object_id: [@submission.biological_specimen_id] })
      elsif @submission.biological_specimen_or_cultural_heritage_object == 'cho'
        if !@submission.cultural_heritage_object_id.present?
          raise StandardError.new "Debug no cho id #{@submission.cultural_heritage_object_id}"
        end
        addl_params.merge!({ physical_object_id: [@submission.cultural_heritage_object_id] })
      end
      if !@submission.device_id.present?
          raise StandardError.new "Debug no device id #{@submission.device_id}"
      end
      model_params.merge!(addl_params)
      @imaging_event_create_params = model_params

    when 'processing_event'
      parents = []
      if @submission.parent_media_not_in_ms.presence
        # absentee parent media
        parents = [@submission.imaging_event_id]
      else
        parents = @submission.parent_media_list&.split(',')
      end
      # in some cases, parents are provided through another route (ajax manually adds to params)
      if parents.present?
        model_params = assign_model_params_parents(model_params, parents)
      end
      @processing_event_create_params = model_params

    when 'media'
      if @submission.raw_or_derived_media == 'raw'
        parent = @submission.imaging_event_id
      elsif @submission.raw_or_derived_media == 'derived'
        parent = @submission.processing_event_id
      end
      if addl_params[:collection_id].present?
        model_params = assign_model_params_collection(model_params, addl_params[:collection_id])
      end
      model_params = assign_model_params_parents(model_params, parent)
      if addl_params[:uploaded_files].present?
        model_params.merge!({ uploaded_files: addl_params[:uploaded_files] })
      end
      if addl_params[:selected_files].present?
        model_params.merge!({ selected_files: addl_params[:selected_files] })
      end
      if addl_params[:organization_transfer_on_publish].present?
        model_params.merge!({ organization_transfer_on_publish: addl_params[:organization_transfer_on_publish] })
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
    raise StandardError.new "Debug empty parent error" if parents.empty?
    parents.each do |parent|
      raise StandardError.new "Debug parent error with #{parent}" if !parent.present?
      parent_attributes.merge!({ i.to_s => { "id" => parent, "_destroy" => "false" } })
      i += 1
    end
    model_params.merge!('work_parents_attributes' => parent_attributes)
  end

  def assign_model_params_collection(model_params, collection_id)
    raise StandardError.new "Debug collection error" if !collection_id.present?

    new_params = {
      "member_of_collection_ids" => ""
    }

    if model_params.key? "member_of_collections_attributes"
      coll_attrs = {}
      i = 0
      model_params["member_of_collections_attributes"].each do |key, attrs|
        return model_params if attrs["id"] == collection_id # Check for duplicates

        coll_attrs.merge!( { i.to_s => { "id" => attrs["id"], "_destroy" => "false" } } )
        i += 1
      end
      coll_attrs.merge!( { i.to_s => { "id" => collection_id, "_destroy" => "false" } } )

      new_params["member_of_collections_attributes"] = coll_attrs
    else
      new_params["member_of_collections_attributes"] = { "0" => { "id" => collection_id, "_destroy" => "false" } }
    end

    model_params.merge!(new_params)
  end

  def create_attachment_if_needed(work, id)
    fields = attachment_fields[work]
    fields.each do |field|
      if field == 'agreement' && params[:media][:agreement_uri].present?
        # skip since agreement url exists
      else
        if field == 'ie_reference'
          formats = Morphosource.reference_attachment_formats
        else
          formats = Morphosource.attachment_formats
        end
        if params[field].present? && formats.include?(File.extname(params[field].original_filename))
          Morphosource::AttachmentService.create(id, field, params[field], formats)
          params.delete(field)
        elsif field == 'agreement' && submission_params[:organization_for_attachment].present?
          Morphosource::AttachmentService.create_copy(id, field, submission_params[:organization_for_attachment])
        end
      end
    end
  end

  def attachment_fields
    {
      'imaging_event' => ['ie_description', 'ie_reference'],
      'processing_event' => ['pe_description'],
      'media' => ['agreement']
    }
  end

  def set_new_fund_code
    return nil if !FundCode.exists?(@submission.fund_code) || !@submission.media_id.present?
    FundCodeMediaAssociation.new(
      fund_code: FundCode.find(@submission.fund_code),
      media: @submission.media_id,
      active: true
    ).save!
  end

  # Methods related to transferring media to organization control

  def create_organization_transfer_request(work)
    work.transfer_media_to_organization
  end

  def organization_media_transfer
    @organization_media_transfer ||= get_organization_media_transfer
  end

  def get_organization_media_transfer
    if (
      @submission.organization_id.present? &&
      Organization.exists?(@submission.organization_id) &&
      (org = Organization.find(@submission.organization_id)).present? &&
      org.data_manager.present?
    )
      transfer_media_immediately? ? :immediate : :publication
    else
      nil
    end
  end

  def transfer_media_immediately?
    ( params.dig(:media, :transfer_management) == 'immediate' ) ||
      ['open', 'restricted_download'].include?(params.dig(:media, :visibility))
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

  def clear_session_submission_settings
    session[:submission] = {}
  end

  def create_attributes_for_actor(model, form_params)
    attributes_for_actor = form_params
    if model == Media
      attributes_for_actor = set_visibilities(attributes_for_actor)
      attributes_for_actor = set_files(attributes_for_actor)
    else
      attributes_for_actor.merge!({ visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC })
    end
    attributes_for_actor
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

    return attributes_for_actor
  end

  def set_files(attributes_for_actor)
    # https://github.com/samvera/hyrax/blob/v2.9.0/app/controllers/concerns/hyrax/works_controller_behavior.rb

    # If they selected a BrowseEverything file, but then clicked the
    # remove button, it will still show up in `selected_files`, but
    # it will no longer be in uploaded_files. By checking the
    # intersection, we get the files they added via BrowseEverything
    # that they have not removed from the upload widget.
    uploaded_files = attributes_for_actor.delete(:uploaded_files) || []
    selected_files = attributes_for_actor.delete(:selected_files)&.values || []
    browse_everything_urls = uploaded_files & selected_files.map { |f| f[:url] }

    # we need the hash of files with url and file_name
    browse_everything_files = selected_files.select { |v| uploaded_files.include?(v[:url]) }
    attributes_for_actor[:remote_files] = browse_everything_files

    # Strip out any BrowseEverthing files from the regular uploads.
    attributes_for_actor[:uploaded_files] = uploaded_files - browse_everything_urls

    return attributes_for_actor
  end

  def create_work(model, attributes_for_actor)
    # TODO: Refactor this to rely on appropriate model methods and not submissions controller
    curation_concern = model.new
    env = Hyrax::Actors::Environment.new(curation_concern, current_ability, attributes_for_actor)
    Hyrax::CurationConcern.actor.create(env)
    return curation_concern.id, curation_concern
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
                :taxonomy_id_array,
                :taxonomy_gbif_key_array,
                :will_create_taxonomy,
                :device_id,
                :will_create_device,
                :device_organization_id,
                :device_no_organization,
                :will_create_device_organization,
                :imaging_event_id,
                :processing_event_id,
                :media_id,
                :collection_id,
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
                :taxonomy_search,
                :organization_search,
                :taxonomy_params_array,
                :organization_for_attachment,
                :fund_code,
                :remote_files
        )
    )
  end

  def find_ancestor_organization
    parent_list = params[:parent_media_list]
    organization_id = params[:organization_id]
    biological_specimen_id = params[:biological_specimen_id]
    cultural_heritage_object_id = params[:cultural_heritage_object_id]

    organization = nil

    if parent_list.present?
      parent = Media.find(parent_list)
      if parent.organizations.present?
        organization = parent.organizations.first
      end
    elsif organization_id.present? && organization_id != 'new'
      organization = Organization.find(organization_id)
    elsif biological_specimen_id.present? && biological_specimen_id != 'new'
      specimen = BiologicalSpecimen.find(biological_specimen_id)
      if specimen.organizations.present?
        organization = specimen.organizations.first
      end
    elsif cultural_heritage_object_id.present? && cultural_heritage_object_id != 'new'
      cho = CulturalHeritageObject.find(cultural_heritage_object_id)
      if cho.organizations.present?
        organization = cho.organizations.first
      end
    end
  end

  def default_media_permissions(organization)
    fields = organization.enforced_permissions_fields

    fields.merge!(
      download_reviewer: format_reviewers_select2(organization.download_reviewer)
    ) if organization.download_reviewer.present?

    fields
  end

  def format_reviewers_select2(reviewers)
    reviewers.map do |ms_id|
      if (u = User.where(ms_id: ms_id)&.first).present?
        { id: u.id, user_key: u.user_key, text: u.email.present? ? u.email : '' }
      end
    end.compact
  end

  # reindex works that have catalog facets depending on metadata from associated work types after all works have been linked with each other.
  def reindex_catalog_works
    return if @submission.media_id.blank?

    catalog_works.each do |work|
      work.update_index if work.present?
    end
  end

  # works that have their own catalog controller
  def catalog_works
    media = [Media.find(@submission.media_id)]
    organizations = media.first.organizations
    objects = media.first.physical_objects
    related_media = media.first.related_media
    media + organizations + objects + related_media
  end

  def device_organizations_search_builder
    @device_organizations_search_builder ||=
      self.device_organizations_search_builder_class.new(self).rows(999999)
  end

  def object_organizations_search_builder
    @object_organizations_search_builder ||=
      self.object_organizations_search_builder_class.new(self).rows(999999)
  end
end
