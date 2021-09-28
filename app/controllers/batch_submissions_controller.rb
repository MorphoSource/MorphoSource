require 'roo'

class BatchSubmissionsController < ApplicationController
  load_and_authorize_resource 
  with_themed_layout 'morphosource_dashboard'
  before_action :instantiate_work_forms

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
      parse_manifest(params[:manifest])

    end

  end


  def parse_manifest(file)
    # column 1 can be ignored
    # field names is on row 7
    # field values start from row 8, column 3    
    error_rows = {}
    error_messages = {}
    xlsx = Roo::Excelx.new(file.tempfile.path)    
    row_index = 8
    xlsx.each_row_streaming(offset: 7, pad_cells: true) do |row| 
      data_row = row.drop(2) 
      data_row.each_with_index do |cell, cell_index|
        error_msg = error_found(field_names[cell_index], cell.value)
        if error_msg.present?
          error_messages[row_index] = error_msg
          error_rows[row_index] = data_row.map { |c| c.value }
        end
      end
      row_index = row_index + 1
    end # /xlsx.each_row_streaming
    render 'result', locals: { rows: error_rows, messages: error_messages, field_names: field_names }
  end

  def error_found(name, val)
    error_msg = ""
    case name
    when "media.media_file"
      if val.nil?
        error_msg = "media.media_file is missing."
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

end
