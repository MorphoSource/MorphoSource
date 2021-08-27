require 'creek'

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
    creek = Creek::Book.new file.tempfile.path, with_headers: true
    error_rows = {}
    error_messages = {}
    sheet = creek.sheets[0]
    data_rows = sheet.simple_rows.to_a.drop(1) # drop the column header row
    data_rows.each_with_index do |row, index|
      if row["file_name"].nil?
        error_rows[index+1] = row
        error_messages[index+1] = "file name is missing"
      end
    end
    byebug
    render 'result', locals: { rows: error_rows, messages: error_messages }
    #redirect_to main_app.batch_submissions_result_path     

  end













end
