require 'roo'

class BatchSubmissionsController < ApplicationController
  load_and_authorize_resource 
  with_themed_layout 'morphosource_dashboard'
  before_action :instantiate_work_forms
  before_action :check_sftp_share_connection, only: [:new]

  def instantiate_work_forms
    @media_form = Hyrax::WorkFormService.build(Media.new, current_ability, self)
  end
  
  def index
  end

  def new
    session[:submission] ||= {}
    form_data = session[:submission]['form_data'] ||= {}
    work_data = session[:submission]['work_data'] ||= {}

    @submission = BatchSubmission.new({
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
      @submission.collection_id = params[:collection]
      @submission.collection_name = Collection.find(@submission.collection_id).title.first
    end

  end # /new

  def manifest
    @manifest ||= params[:manifest]
  end

  def manifest_format_valid?
    Morphosource.manifest_formats.include? File.extname(manifest.original_filename).downcase
  end

  def submit
    if params[:manifest].present?
      unless manifest_format_valid?
        flash[:error] = 'The file uploaded is invalid.  Please upload a file in this format: ' + Morphosource.manifest_formats.join(',')
        return redirect_to main_app.new_batch_submission_path

      end
      @xlsx = Roo::Excelx.new(params[:manifest].tempfile.path)
      @params = params
      parse_manifest

    end

  end

  def parse_manifest
    # field names is on row 7 
    # field values start from row 8, column 3 (column 1 and 2 can be skipped)   
    general_error_msg = ""
    error_rows = {}
    error_messages = {}
    error_cell_numbers = {}
    row_index = 8
    @xlsx.each_row_streaming(offset: 7, pad_cells: true) do |row| 
      data_row = row.drop(2) 
      row_cell_errors = []
      row_cell_numbers = []
      data_row.each_with_index do |cell, cell_index|
        begin
          general_error_msg = "There are validation errors.  Please check the details below."
          error_msg = error_found(field_names[cell_index], cell, row_index)
          if error_msg.present?
            row_cell_errors << error_msg
            error_rows[row_index] = data_row.map { |c| c.present? ? c.value.to_s : "" }
            row_cell_numbers << cell_index
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
      error_cell_numbers[row_index] = row_cell_numbers
      row_index = row_index + 1
    end # /lopping rows /xlsx.each_row_streaming
    render 'result', locals: { general_error_msg: general_error_msg, error_rows: error_rows, error_messages: error_messages, error_cell_numbers: error_cell_numbers, field_names: field_names, row_count: row_index - 8 }
  end

  def error_found(field_name, cell, current_row)
    val = cell.present? ? cell.value.to_s : ""
    error_msg = ""
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
    when "media.publication_status"
      unless valid_publication_status.include? val
        error_msg = "media.publication_status: Please enter a valid value " + valid_publication_status.to_s
      end
    when "media.media_type"
      unless valid_media_types.include? val
        error_msg = "media.media_type: Please enter a valid value " + valid_media_types.to_s
      end
    when "media.parent_file"
      # IF value is present, another row must contain this value in media.media_file
      if val.present? 
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

        if @xlsx.cell(current_row, field_column("media.parent_ms_id")).present?
          error_msg = "A value can be present in media.parent_file_name or media.parent_ms_id, but not in both."
        end
      end
    when "media.parent_ms_id"
      if val.present?
        val = pad(val.to_s)
        unless Media.where(id:val).present?
          error_msg = "media.parent_ms_id: Existing media #{val} not found."
        end
      end
    when "biological_specimen.ms_id"
      if val.present?
        val = pad(val.to_s)
        unless BiologicalSpecimen.where(id:val).present?
          error_msg = "biological_specimen.ms_id: Existing biological specimen #{val} not found."
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
      if val.present?
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
      if val.present?
        organization_institution_code = @params["organization_institution_code"]
        if organization_institution_code.present?
          unless organization_institution_code.upcase.split(', ').include? val.upcase
            error_msg = "biological_specimen.institution_code: It does not match the institution code from the pre-selected organization: #{organization_institution_code}"
          end
        end
      end


    end
    return error_msg
  end

  def field_names
    @field_names ||= 
    ["media.media_file",
    "media.preview_file",
    "media.publication_status",
    "media.media_type",
    "media.parent_file",
    "media.parent_ms_id",
    "biological_specimen.ms_id",
    "biological_specimen.idigbio_uuid",
    "biological_specimen.occurrence_id",
    "biological_specimen.institution_code",
    "biological_specimen.collection_code",
    "biological_specimen.catalog_number",
    "media.part",
    "media.short_description",
    "media.side",
    "media.description",
    "media.creator",
    "media.orientation",
    "media.identifier",
    "media.keyword",
    "media.date_created",
    "media.related_url",
    "media.x_spacing",
    "media.y_spacing",
    "media.z_spacing",
    "media.slice_thickness",
    "media.series_type",
    "media.unit",
    "media.map_type",
    "biological_specimen.identifier",
    "biological_specimen.related_url",
    "biological_specimen.date_created",
    "biological_specimen.creator",
    "biological_specimen.description",
    "biological_specimen.latitude",
    "biological_specimen.longitude",
    "biological_specimen.numeric_time",
    "biological_specimen.original_location",
    "biological_specimen.periodic_time",
    "biological_specimen.is_type_specimen",
    "biological_specimen.sex",
    "biological_specimen.vouchered",
    "taxonomy.taxonomy_genus",
    "taxonomy.taxonomy_species",
    "taxonomy.taxonomy_subspecies",
    "imaging_event.description",
    "imaging_event.creator",
    "imaging_event.software",
    "imaging_event.date_created",
    "imaging_event.ct.exposure_time",
    "imaging_event.ct.flux_normalization",
    "imaging_event.ct.geometric_calibration",
    "imaging_event.ct.shading_correction",
    "imaging_event.ct.filter_material",
    "imaging_event.ct.filter_thickness",
    "imaging_event.ct.frame_averaging",
    "imaging_event.ct.projections",
    "imaging_event.ct.voltage",
    "imaging_event.ct.power",
    "imaging_event.ct.amperage",
    "imaging_event.ct.surrounding_material",
    "imaging_event.ct.xray_tube_type",
    "imaging_event.ct.target_type",
    "imaging_event.ct.detector_type",
    "imaging_event.ct.detector_pixels_x",
    "imaging_event.ct.detector_pixel_size_x",
    "imaging_event.ct.detector_pixels_y",
    "imaging_event.ct.detector_pixel_size_y",
    "imaging_event.ct.detector_configuration",
    "imaging_event.ct.source_object_distance",
    "imaging_event.ct.source_detector_distance",
    "imaging_event.ct.target_material",
    "imaging_event.ct.rotation_number",
    "imaging_event.ct.phase_contrast",
    "imaging_event.ct.optical_magnification",
    "imaging_event.ct.acquisition_type",
    "imaging_event.photogrammetry.focal_length_type",
    "imaging_event.photogrammetry.background_removal",
    "imaging_event.photography.lens_make",
    "imaging_event.photography.lens_model",
    "imaging_event.photography.light_source",
    "processing_event.creator",
    "processing_event.date_created",
    "processing_event.software",
    "processing_event.description"]
  end

  #def field_value(row, field)
  #  # this returns the value of a specified field on specified row
  #  @xlsx.cell(row, field_column(field))
  #end

  def field_column(field) 
    # this returns the actual column number of a field (by adding first 2 columns and "0")
    field_names.index(field) + 3 
  end

  def valid_publication_status
    @valid_publication_status ||= Morphosource::PermissionsHelper::PUBLICATION_OPTIONS.map { |o| o[1] }
  end

  def valid_media_types
    @valid_media_types ||= Morphosource::MediaTypesService.new.select_all_options.map { |o| o[1] }
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

  def pad(id)
    if id.length < 9
      ("0" * (9 - id.length)) + id
    else
      id
    end
  end

end
