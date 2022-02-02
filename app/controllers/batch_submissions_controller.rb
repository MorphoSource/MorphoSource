require 'roo'

class BatchSubmissionsController < ApplicationController
  load_and_authorize_resource 
  with_themed_layout 'morphosource_dashboard'
  before_action :instantiate_work_forms, only: [:new]
  before_action :check_sftp_share_connection, only: [:new]
  before_action :check_params, only: [:submit]
  after_action :create_manifest_object, only: [:submit]

  def instantiate_work_forms
    @media_form = Hyrax::WorkFormService.build(Media.new, current_ability, self)
  end
  
  def index
  end

  def new
    session[:batch_submission] ||= {}
    form_data = session[:batch_submission]['form_data'] ||= {}
    work_data = session[:batch_submission]['work_data'] ||= {}

    @batch_submission = BatchSubmission.new({
      form_data: form_data,
      work_data: work_data
    })

    @organizations = Organization.all_solr
    @organizations_select2 = @organizations.map do |o|
      {
        id: o['id'],
        text: "#{[o['institution_name_tesim']&.first, o['title_tesim']&.first].compact.join(', ')} (#{o['institution_code_tesim']&.join('/')}:#{o['collection_code_tesim']&.join('/')})",
        organization_type: o['organization_type_tesim']&.first,
        institution_name: o['institution_name_tesim']&.first,
        title: o['title_tesim']&.first,
        institution_code: o['institution_code_tesim']&.join(', '),
        collection_code: o['collection_code_tesim']&.join(', '),
        recordset_id: o['recordset_id_tesim']&.join(', '),
        related_url: o['related_url_tesim']&.first,
        address: o['address_tesim']&.first,
        city: o['city_tesim']&.first,
        state_province: o['state_province_tesim']&.first,
        country: o['country_tesim']&.first,
        postal_code: o['postal_code_tesim']&.first,
        description: o['description_tesim']&.first,
        contact_person: o['contact_person_tesim']&.first,
        devices: o['member_ids_ssim']
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

    if params[:collection] && Collection.exists?(params[:collection])
      @batch_submission.collection_id = params[:collection]
      @batch_submission.collection_name = Collection.find(@batch_submission.collection_id).title.first
    end

  end # /new

  def manifest
    @manifest ||= params[:manifest]
  end

  def manifest_format_valid?
    Morphosource.manifest_formats.include? File.extname(manifest.original_filename).downcase
  end

  def submit
#byebug
    @submission_yaml = YAML.load_file(Rails.root.join('config','submission.yml'))
    @xlsx = Roo::Excelx.new(manifest.tempfile.path)
    @modality_selected = @params["batch_submission"]["modality"]
    @manifest_is_valid = false
    parse_manifest
  end

  def create_manifest_object
    if @manifest_is_valid
      input_path = manifest.tempfile.path
      media_path = user_share_full_path
      admin_user = User.where(email:Hyrax.config.system_admin_email).first
      depositor = current_user
      organization_id = request.params["organization_id"]
      device_id = request.params["batch_submission"]["device_id"]
      if request.params["batch_submission"]["on_behalf_of"].present?
        on_behalf_of = User.where(ms_id: request.params["batch_submission"]["on_behalf_of"]).first
      end
      collection_ids = []
      if request.params["media"].present?
        if request.params["media"]["member_of_collections_attributes"].present?
          request.params["media"]["member_of_collections_attributes"].each do |k, v|
            collection_ids << v["id"] if v["_destroy"] == "false"
          end
        end
      end
      fund_code_id = request.params["batch_submission"]["fund_code"]
      media_ownership_fields = request.params["batch_submission"]["media"]
      @manifest_object = BatchSubmissionTools::Ms2Batch::Manifest.new(input_path:input_path, media_path:media_path, admin_user:admin_user, depositor:depositor, on_behalf_of:on_behalf_of, collection_ids:collection_ids, fund_code_id:fund_code_id, organization_id:organization_id, device_id:device_id, media_ownership_fields:media_ownership_fields).to_h
byebug

      ingest
    else

    end

  end

  def ingest
    #::BatchSubmissionJobs::Ms2Batch::ControlJob.perform_now(session[:manifest_object])
    ::BatchSubmissionJobs::Ms2Batch::ControlJob.perform_now(@manifest_object)
  end

  def parse_manifest
    # field names is on row 7 
    # field values start from row 8, column 3 (column 1 and 2 can be skipped)   
    general_error_msg = ""
    general_warning_msg = ""
    error_rows = {}
    error_messages = {}
    error_cell_numbers = {}
    warn_rows = {}
    warn_messages = {}
    warn_cell_numbers = {}
    row_index = 8
    @xlsx.each_row_streaming(offset: 7, pad_cells: true) do |row| 
      data_row = row.drop(2) 
      row_cell_errors = []
      error_row_cell_numbers = []
      row_cell_warnings = []
      warn_row_cell_numbers = []
      data_row.each_with_index do |cell, cell_index|
        begin
          error_msg, warn_msg = error_found(field_names[cell_index], cell, row_index)
          if error_msg.present?
            row_cell_errors << error_msg
            error_rows[row_index] = data_row.map { |c| c.present? ? c.value.to_s : "" }
            error_row_cell_numbers << cell_index
          elsif warn_msg.present?
            row_cell_warnings << warn_msg
            warn_rows[row_index] = data_row.map { |c| c.present? ? c.value.to_s : "" }
            warn_row_cell_numbers << cell_index
          end
        rescue => e
          Rails.logger.debug "Exception in BatchSubmissionsController: #{e.message} -- #{e.inspect} -- #{e.backtrace}"
          general_error_msg = "ERROR: There are problems parsing some rows in the file.  Please check the details below."
          row_cell_errors = ["This row is skipped.  If the row appears to be blank, please try deleting or clearing the row."]
          error_rows[row_index] = data_row.map { |c| c.present? ? c.value : "" }
          break # skip the rest of the cells
        end
      end # /looping cells
      error_messages[row_index] = row_cell_errors 
      error_cell_numbers[row_index] = error_row_cell_numbers
      warn_messages[row_index] = row_cell_warnings 
      warn_cell_numbers[row_index] = warn_row_cell_numbers
      row_index = row_index + 1
    end # /lopping rows /xlsx.each_row_streaming
    row_count = row_index - 8
    if error_rows.count > 0
      general_error_msg = "There are validation errors.  Please check the details below."
      render 'validation_fail', locals: { 
        general_error_msg: general_error_msg, 
        error_rows: error_rows, 
        error_messages: error_messages, 
        error_cell_numbers: error_cell_numbers, 
        warn_rows: warn_rows, 
        warn_messages: warn_messages, 
        warn_cell_numbers: warn_cell_numbers, 
        field_names: field_names, 
        row_count: row_count }
      @manifest_is_valid = false
    else
#      save_params_to_session
#      instantiate_work_forms      
#      render :action => 'new'
#      render 'validation_pass', locals: { row_count: row_count }
      
      #todo: remove validation_pass template later if not needed
      render 'index', locals: { 
        warn_rows: warn_rows, 
        warn_messages: warn_messages, 
        warn_cell_numbers: warn_cell_numbers, 
        field_names: field_names, 
        row_count: row_count }
      @manifest_is_valid = true
    end    
  end

  def save_params_to_session
    session[:batch_submission].deep_merge!(permitted_params) #.deep_merge!(batch_submission_params) 
#byebug
  end

  def manifest_params
    params
      .fetch(:manifest, {})
      .permit(
              { :form_data => {} },
              { :work_data => {} }
      )
  end

  def permitted_params
    params.permit(
      :organization_institution_code,
      :organization_recordset_id
    )
  end

  def coerce_strings_to_booleans(params)
    params.transform_values {|p| (p == 'true' || p == 'false') ? ActiveModel::Type::Boolean.new.cast(p) : p  }
  end

  def batch_submission_params
    coerce_strings_to_booleans(
      params
        .fetch(:batch_submission, {})
        .permit(
                { :form_data => {} },
                { :work_data => {} }
        )
    )
  end

  def error_found(field_name, cell, current_row)
    val = cell.present? ? cell.value.to_s : ""
    error_msg = ""
    warn_msg = ""
    case field_name
    when "media.media_file"
      if !val.present?
        error_msg = "media.media_file: Please enter a value."
      elsif !File.exist?(user_share_full_path + val)
        error_msg = "media.media_file: File #{val} cannot be found. Please check your shared folder."
      end
    when "media.preview_file"
      if val.present? && !File.exist?(user_share_full_path + val)
        error_msg = "media.preview_file: File #{val} cannot be found. Please check your shared folder."
      end
    when "media.media_type"
      if valid_media_types.include? val
        if val.downcase != "other" 
          # check if media_type value +  pre-selected modality is a permitted combination
          if @submission_yaml['status'][val][@modality_selected] == 'none'
          error_msg = "media.media_type: The combination of media type #{val} and pre-selected modality #{@modality_selected} is not permitted.  Please provide a different media type or select a different modality. "
          end
        end
      else
        error_msg = "media.media_type: Please enter a valid value: " + valid_media_types.to_s.gsub(/\[|\]/, '')
      end
    when "media.parent_file"
      # IF value is present, another row must contain this value in media.media_file
      if val.present? 
        if @xlsx.cell(current_row, field_column("media.parent_ms_id")).present?
          error_msg = "A value can be present in media.parent_file or media.parent_ms_id, but not in both."
        else
          # look for the val in the media_file column
          parent_media_found_row = @xlsx.column(field_column("media.media_file")).index(val)
          if parent_media_found_row.present?
            parent_media_row = parent_media_found_row + 1
            if parent_media_row == current_row
              error_msg = "media.parent_file #{val} cannot be media.media_file in the same row."
            end
          else
            error_msg = "media.parent_file #{val} not found in another row."
          end
        end
      end
    when "media.parent_ms_id"
      if @xlsx.cell(current_row, field_column("media.parent_file")).present?
        # the error_msg should be set in the media.parent_file block already
        #error_msg = "A value can be present in media.parent_file or media.parent_ms_id, but not in both."
      else
        if val.present?
          unless Media.where(id:pad(val.to_s)).present?
            error_msg = "media.parent_ms_id: Existing media #{val} not found."
          end
        end
      end
    when /^media\.(.*)$/
      # note that specific media.* fields (e.g. media.media_type) should be handled above already
      sub_field_name = $1
      media_type = @xlsx.cell(current_row, field_column("media.media_type"))
      if valid_media_types.include? media_type # no need to check unless media type is valid
        @media_type = media_type
        if val.present? && field_to_reject_for_media_type?(media_type, sub_field_name)
          error_msg = "#{field_name}: Value should not be present for media type #{media_type}."
        else
          # value that is not rejected (accepted for the media type) can be validated here
          error_msg = error_by_type(field_name, val)
        end
      end
    when "biological_specimen.ms_id"
      if val.present?
        val = pad(val.to_s)
        unless BiologicalSpecimen.where(id:val).present?
          error_msg = "biological_specimen.ms_id: Existing biological specimen #{val} not found."
        end
        ignored_values = []
        if @xlsx.cell(current_row, field_column("biological_specimen.idigbio_uuid")).present? 
          ignored_values << "biological_specimen.idigbio_uuid"
        end
        if @xlsx.cell(current_row, field_column("biological_specimen.occurrence_id")).present? 
          ignored_values << "biological_specimen.occurrence_id"
        end
        if @xlsx.cell(current_row, field_column("biological_specimen.institution_code")).present? 
          ignored_values << "biological_specimen.institution_code"
        end
        if @xlsx.cell(current_row, field_column("biological_specimen.collection_code")).present?
          ignored_values << "biological_specimen.collection_code"
        end
        if @xlsx.cell(current_row, field_column("biological_specimen.catalog_number")).present?
          ignored_values << "biological_specimen.catalog_number"
        end
        if ignored_values.present?
          warn_msg += "The following are ignored since biological_specimen.ms_id exists: " + ignored_values.join(', ')
        end
      else
        if !@xlsx.cell(current_row, field_column("biological_specimen.idigbio_uuid")).present? &&
           !@xlsx.cell(current_row, field_column("biological_specimen.occurrence_id")).present? &&
           !@xlsx.cell(current_row, field_column("biological_specimen.institution_code")).present? &&
           !@xlsx.cell(current_row, field_column("biological_specimen.collection_code")).present? &&
           !@xlsx.cell(current_row, field_column("biological_specimen.catalog_number")).present?
        
          error_msg = "One of the following must have a value: biological_specimen.ms_id, biological_specimen.idigbio_uuid, biological_specimen.occurrence_id, biological_specimen.institution_code, biological_specimen.collection_code, and biological_specimen.catalog_number."
        end
      end
    when "biological_specimen.idigbio_uuid"
      if val.present? && !@xlsx.cell(current_row, field_column("biological_specimen.ms_id")).present?
        idb_result = Morphosource::IDigBioSearchService.call( { "idigbio_uuid" => val } )
        if idb_result.present?
          # If the pre-selected organization has a recordset_id, specimen matching UUID via iDigBio API must have a 
          # recordset_id matching the recordset_id of the pre-selected organization
          organization_recordset_id = @params["organization_recordset_id"]
          if organization_recordset_id.present?
            idb_recordset = idb_result.first["indexTerms"]["recordset"] # todo: might need to check if this will return multiple values
            unless organization_recordset_id.upcase.split(', ').include? idb_recordset.upcase
              error_msg += "Specimen in iDigBio has recordset id #{idb_recordset} which does not match the pre-selected organization's recordset id: #{organization_recordset_id}. "
            end
          end        
          # If the pre-selected organization has existing institution codes, specimen matching UUID via iDigBio API 
          # must have iDigBio-supplied institution code matching pre-selected organization (case-insensitive)
          organization_institution_code = @params["organization_institution_code"]
          if organization_institution_code.present?
            idb_institution_code = idb_result.first["indexTerms"]["institutioncode"] # todo: might need to check if this will return multiple values
            unless organization_institution_code.upcase.split(', ').include? idb_institution_code.upcase
              error_msg += "Specimen in iDigBio has institution code #{idb_institution_code} which does not match the pre-selected organization's institution code: #{organization_institution_code}"
            end
          end
        else
          error_msg = "Cannot found specimen in iDigBio."
        end
        error_msg = "biological_specimen.idigbio_uuid: " + error_msg if error_msg.present?
      end
    when "biological_specimen.institution_code"
      # If pre-selected organization has existing institution codes, value must match one of the institution codes from the pre-selected organization
      if val.present? && !@xlsx.cell(current_row, field_column("biological_specimen.ms_id")).present?
        organization_institution_code = @params["organization_institution_code"]
        if organization_institution_code.present?
          unless organization_institution_code.upcase.split(', ').include? val.upcase
            error_msg = "biological_specimen.institution_code: It does not match the institution code from the pre-selected organization: #{organization_institution_code}"
          end
        end
      end
    when /^imaging_event\.(.*)$/
      case $1
      when /^(ct|photogrammetry|photography)\.(.*)$/
        # handle modality specific fields 
        field_modality = $1
        if val.present?
          if field_modality.downcase == modality_mapped(@modality_selected).downcase
            error_msg = error_by_type(field_name, val)
          else
            # no need to check the values if they should not be present 
            error_msg = "#{field_name}: Value should not be present when modality #{@modality_selected} is pre-selected."
          end
        end  
      else
        # handle non-modality specific fields 
        error_msg = error_by_type(field_name, val)
      end
    when /^(biological_specimen|taxonomy|processing_event)\.(.*)$/
      # note that specific *.* fields should be handled above already
      if val.present?        
        error_msg = error_by_type(field_name, val)
      end
    end
    return error_msg, warn_msg
  end

  def error_by_type(field_name, val)
    error_msg = ""
    case field_types[field_name]
    when /^controlled(_required)?$/
      if !val.present?
        if $1.present?
          error_msg = "#{field_name}: Please enter a valid value."
        end
      else
        unless valid_values_for(field_name).include? val
          error_msg = "#{field_name}: Please enter a valid value: " + valid_values_for(field_name).to_s.gsub(/\[|\]/, '')
        end
      end
    when "boolean"
      unless valid_boolean.include? val
        error_msg = "#{field_name}: Please enter a valid value: " + valid_boolean.to_s.gsub(/\[|\]/, '')
      end
    when /^number(_RequiredByMediaType_.*)?$/
      if $1.present?
        by_media_type = $1.split('_').last
        if by_media_type == @media_type
          if !val.present?
            error_msg = "#{field_name}: Value should be present for media type #{by_media_type}."
          else
            required = true
          end
        else
          required = false
        end
      else
        required = false
      end
      if (!error_msg.present?)
        unless (!val.present?) && (!required)
          unless is_number? val
            error_msg = "#{field_name}: Please enter a valid number."
          end
        end
      end
    when "integer"
      unless is_integer? val
        error_msg = "#{field_name}: Please enter a valid integer."
      end
    when "date"
      unless is_date? val
        error_msg = "#{field_name}: Please enter a valid date in YYYY-MM-DD or MM-DD-YYYY format."
      end
    end
    return error_msg
  end

  def is_integer?(str)
    Integer(str) != nil rescue false
  end

  def is_number?(str)
    Float(str) != nil rescue false
  end

  def is_date?(str)
    case str
    when /^(\d{4})\-(\d{2})\-(\d{2})$/
      Date.valid_date? $1.to_i, $2.to_i, $3.to_i
    when /^(\d{2})\-(\d{2})\-(\d{4})$/
      Date.valid_date? $3.to_i, $2.to_i, $1.to_i
    else
      false
    end
  end

  def field_names
    @field_names ||= field_types.keys
  end

  def field_types
    @field_types ||= {
      "media.media_file" => "text",
      "media.preview_file" => "text",
      "media.publication_status" => "controlled_required",
      "media.media_type" => "controlled_required",
      "media.parent_file" => "text",
      "media.parent_ms_id" => "text",
      "biological_specimen.ms_id" => "text",
      "biological_specimen.idigbio_uuid" => "text",
      "biological_specimen.occurrence_id" => "text",
      "biological_specimen.institution_code" => "text",
      "biological_specimen.collection_code" => "text",
      "biological_specimen.catalog_number" => "text",
      "media.part" => "text",
      "media.short_description" => "text",
      "media.side" => "controlled",
      "media.description" => "text",
      "media.creator" => "text",
      "media.orientation" => "text",
      "media.identifier" => "text",
      "media.keyword" => "text",
      "media.date_created" => "date",
      "media.related_url" => "text",
      "media.x_spacing" => "number_RequiredByMediaType_CTImageSeries",
      "media.y_spacing" => "number_RequiredByMediaType_CTImageSeries",
      "media.z_spacing" => "number_RequiredByMediaType_CTImageSeries",
      "media.slice_thickness" => "number",
      "media.series_type" => "controlled",
      "media.unit" => "controlled",
      "media.map_type" => "controlled",
      "biological_specimen.identifier" => "text",
      "biological_specimen.related_url" => "text",
      "biological_specimen.date_created" => "date",
      "biological_specimen.creator" => "text",
      "biological_specimen.description" => "text",
      "biological_specimen.latitude" => "number",
      "biological_specimen.longitude" => "number",
      "biological_specimen.numeric_time" => "text",
      "biological_specimen.original_location" => "text",
      "biological_specimen.periodic_time" => "text",
      "biological_specimen.is_type_specimen" => "boolean",
      "biological_specimen.sex" => "controlled",
      "biological_specimen.vouchered" => "boolean",
      "taxonomy.taxonomy_genus" => "text",
      "taxonomy.taxonomy_species" => "text",
      "taxonomy.taxonomy_subspecies" => "text",
      "imaging_event.description" => "text",
      "imaging_event.creator" => "text",
      "imaging_event.software" => "text",
      "imaging_event.date_created" => "text",
      "imaging_event.ct.exposure_time" => "number",
      "imaging_event.ct.flux_normalization" => "boolean",
      "imaging_event.ct.geometric_calibration" => "boolean",
      "imaging_event.ct.shading_correction" => "boolean",
      "imaging_event.ct.filter" => "text",
      "imaging_event.ct.frame_averaging" => "text",
      "imaging_event.ct.projections" => "text",
      "imaging_event.ct.voltage" => "text",
      "imaging_event.ct.power" => "text",
      "imaging_event.ct.amperage" => "text",
      "imaging_event.ct.surrounding_material" => "text",
      "imaging_event.ct.xray_tube_type" => "text",
      "imaging_event.ct.target_type" => "controlled",
      "imaging_event.ct.detector_type" => "controlled",
      "imaging_event.ct.detector_pixels_x" => "integer",
      "imaging_event.ct.detector_pixel_size_x" => "number",
      "imaging_event.ct.detector_pixels_y" => "integer",
      "imaging_event.ct.detector_pixel_size_y" => "number",
      "imaging_event.ct.detector_configuration" => "controlled",
      "imaging_event.ct.source_object_distance" => "text",
      "imaging_event.ct.source_detector_distance" => "text",
      "imaging_event.ct.target_material" => "text",
      "imaging_event.ct.rotation_number" => "number",
      "imaging_event.ct.phase_contrast" => "boolean",
      "imaging_event.ct.optical_magnification" => "boolean",
      "imaging_event.ct.acquisition_type" => "controlled",
      "imaging_event.photogrammetry.focal_length_type" => "controlled",
      "imaging_event.photogrammetry.background_removal" => "text",
      "imaging_event.photography.lens_make" => "text",
      "imaging_event.photography.lens_model" => "text",
      "imaging_event.photography.light_source" => "controlled",
      "processing_event.creator" => "text",
      "processing_event.date_created" => "date",
      "processing_event.software" => "text",
      "processing_event.description" => "text"
    }
  end

  def field_column(field) 
    # this returns the actual column number of a field (by adding first 2 columns and "0")
    field_names.index(field) + 3 
  end

  def valid_values_for(field)
    method_name = "valid_" + field.gsub('.', '_')
    return send(method_name)
  end

  def valid_media_publication_status
    @valid_media_publication_status ||= ['Open', 'RestrictedDownload', 'Private']
  end

  def valid_media_types
    @valid_media_types ||= Morphosource::MediaTypesService.new.select_all_options.map { |o| o[1] }
  end  

  def valid_media_side
    @valid_media_side ||= ["Left", "Midline", "NotApplicable", "Right", "Unknown"]
  end

  def valid_media_series_type
    @valid_media_series_type ||= ['Projections', 'Reconstructed image stack', 'Sinograms']
  end

  def valid_media_unit
    @valid_media_unit ||= ['Cm', 'Ft', 'In', 'Km', 'M', 'Mi', 'Mm']
  end

  def valid_media_map_type
    @valid_media_map_type ||= ['Color', 'Normal']
  end

  def valid_biological_specimen_sex
    @valid_biological_specimen_sex ||= ['Female', 'Male', 'Unknowable', 'Undetermined', 'Hermaphrodite', 'Gynandromorph']
  end

  def valid_imaging_event_ct_target_type
    @valid_imaging_event_ct_target_type ||= ['Reflection', 'Transmission']
  end

  def valid_imaging_event_ct_detector_type
    @valid_imaging_event_ct_detector_type ||= ['Direct (X-Ray photoconductor)', 'Scintillator (Phosphor used)', 'Storage (Storage Phosphor)', 'Film (Scanned film/screen)']
  end

  def valid_imaging_event_ct_detector_configuration
    @valid_imaging_event_ct_detector_configuration ||= ['Area (single or tiled detector)', 'Slot (scanned slot, slit, or spot)']
  end

  def valid_imaging_event_ct_acquisition_type
    @valid_imaging_event_ct_acquisition_type ||= ['ConstantAngle', 'Free', 'Sequenced', 'Spiral', 'Stationary']
  end

  def valid_imaging_event_photogrammetry_focal_length_type
    @valid_imaging_event_photogrammetry_focal_length_type ||= ['Variable', 'Fixed']
  end

  def valid_imaging_event_photography_light_source
    @valid_imaging_event_photography_light_source ||= ['Strobe', 'Static', 'Patterned', 'Cross polarized']
  end

  def valid_boolean
    @valid_boolean ||= ['Yes', 'No', 'Y', 'N', 'true', 'false', '0', '1']
  end

  def field_to_reject_for_media_type?(media_type, field)
    case media_type
    when 'CTImageSeries'  
      ['map_type'].include? field
    when 'PhotogrammetryImageSeries'
      ['x_spacing', 'y_spacing', 'z_spacing', 'slice_thickness', 'unit', 'map_type'].include? field
    when 'Mesh'
      ['series_type', 'x_spacing', 'y_spacing', 'z_spacing', 'slice_thickness'].include? field
    else
      ['series_type', 'x_spacing', 'y_spacing', 'z_spacing', 'slice_thickness', 'unit', 'map_type'].include? field
    end
  end
  
  def pad(id)
    if id.length < 9
      ("0" * (9 - id.length)) + id
    else
      id
    end
  end

  def modality_mapped(m)
    case m
    when 'MicroNanoXRayComputedTomography'
      'ct'
    when 'MagneticResonanceImaging'
      'MRI'
    when 'PositronEmissionTomography'
      'PET'
    when 'SinglePhotonEmissionComputedTomography'
      'SPECT'
    when 'NeutronComputedTomography'
      'NCT'
    when 'SynchrotronImaging'
      'Synchro'
    when 'NeutrinoImaging'
      'Neutrino'
    when 'Photogrammetry'
      'photogrammetry'
    when 'StructuredLight'
      'StrLight'
    when 'LaserScan'
      'Laser'
    when 'ConfocalImageStacking'
      'Confocal'
    when 'Infrared'
      'Infrared'
    when 'ReflectanceTransformationImaging'
      'RTI'
    when 'Photography'
      'photography'
    when 'ScanningElectronMicroscopy'
      'SEM'
    when 'BornDigital'
      'BD'
    when 'XRay'
      'XRay'
    when 'LaserAidedProfiling'
      'LAP'
    when 'Video'
      'Video'
    else
      'Etc'
    end
  end

  private

    def check_params
      @params = params
      if @params[:manifest].present?
        unless manifest_format_valid?
          flash[:error] = 'The file uploaded is invalid.  Please upload a file in this format: ' + Morphosource.manifest_formats.join(',')
          return redirect_to main_app.new_batch_submission_path
        end
      else 
        flash[:error] = 'The manifest file is missing. '
        return redirect_to main_app.new_batch_submission_path
      end
      unless @params["batch_submission"]["modality"].present?
        flash[:error] = 'The modality is missing. '
        return redirect_to main_app.new_batch_submission_path
      end
    end

    def user_share_full_path
      @user_share_full_path ||= begin
        user_set_path = current_user.sftp_share
        if !user_set_path.present?
          "NOT_FOUND"
        elsif Dir.exist?(Hyrax.config.sftp_share_root + user_set_path) 
          Hyrax.config.sftp_share_root + user_set_path + '/' unless user_set_path.end_with?('/')
        elsif Dir.exist?(user_set_path)
          user_set_path + '/' unless user_set_path.end_with?('/')
        else
          "NOT_FOUND"
        end
      end
    end

    def check_sftp_share_connection
      if user_share_full_path == "NOT_FOUND"
        render 'not_connected'      
      end
    end

end
