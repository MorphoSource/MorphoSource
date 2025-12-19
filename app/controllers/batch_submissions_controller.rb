require 'roo'

class BatchSubmissionsController < ApplicationController
  include BatchSubmissionTools::Ms2Batch::BatchSubmission
  include Hyrax::WorksControllerBehavior
  include SubmissionsControllerBehavior

  load_and_authorize_resource
  with_themed_layout 'morphosource_dashboard'
  before_action :instantiate_work_forms, only: [:new]
  before_action :check_batch_submission_access, only: [:index, :new, :submit, :ingest]
  before_action :check_new_submit_allowed, only: [:new, :submit, :ingest]
  before_action :check_params, only: [:submit]
  before_action :check_request_manifest_object, :check_dup_job, only: [:ingest]
  after_action :start_ingest_job, only: [:ingest]

  class_attribute :device_organizations_search_builder_class
  self.device_organizations_search_builder_class = Morphosource::Catalog::Organizations::DeviceOrganizationsCatalogSearchBuilder

  class_attribute :object_organizations_search_builder_class
  self.object_organizations_search_builder_class = Morphosource::Catalog::Organizations::ObjectOrganizationsCatalogSearchBuilder

  # return all possible organization records for organization search
  configure_blacklight do |config|
    config.max_per_page = 1000000
  end

  attr_accessor :parent_media_row, :parent_media_id

  def instantiate_work_forms
    @media_form = Hyrax::WorkFormService.build(Media.new, current_ability, self)
  end

  def index
    last_job = current_user.last_batch_submission_job
    if last_job.present?
      check_job_failure(last_job) unless (last_job.status == "failed" ||  last_job.status == "completed")
    end
    render 'index', locals: { job: last_job }
  end

  def check_job_failure(last_job)
    # check if the last job has actually failed without throwing an exception
    failure_found_indexes = []
    exceptions = []
    1.upto(Resque::Failure.count) do |idx|
      job = Resque::Failure.all(idx)
      if job.present?
        begin
          if job['payload']['args'][0]['job_id'] == last_job.job_id
            failure_found_indexes << idx
            exceptions << "Exception: #{job['exception']}, Error: #{job['error']}"
          end
        rescue => e
          Rails.logger.debug "iN check_job_failure, Exception: #{e.message} -- #{e.inspect} -- #{e.backtrace}"
        end
      end
    end
    if failure_found_indexes.present?
      # update both ActiveJob and BackgroundJob
      status = ActiveJob::Status.get(last_job.job_id)
      status.update(status: :failed)
      status.update(exception: exceptions.join('; '))
      last_job.update_status("failed", exceptions.join('; '))
    end
  end

  def new
    session[:batch_submission] ||= {}
    form_data = session[:batch_submission]['form_data'] ||= {}
    work_data = session[:batch_submission]['work_data'] ||= {}

    @batch_submission = BatchSubmission.new({
      form_data: form_data,
      work_data: work_data
    })

    get_organizations_and_devices

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
    batch_file_validity = BatchSubmissionTools::Ms2Batch::BatchFileValidator.new(
      xlsx_file: Roo::Excelx.new(manifest.tempfile.path),
      user: current_user,
      organization_id: request.params["organization_id"],
      modality: @params["batch_submission"]["modality"]
    ).validate

    validity_status = batch_file_validity[:status]
    validity_data = (batch_file_validity[:data] || {}).slice(
      :general_error_msg,
      :error_rows,
      :error_messages,
      :error_cell_numbers,
      :warn_rows,
      :warn_messages,
      :warn_cell_numbers,
      :field_names,
      :row_count
    )

    if validity_status == "success"
      create_manifest_object
      render 'validation_success', locals: { manifest_object: @manifest_object }.merge(validity_data)
    elsif validity_status == "fail"
      render 'validation_fail', locals: validity_data
    else
      raise "Unexpected error checking batch file validity: #{batch_file_validity}"
    end
  end

  def create_manifest_object
    input_path = manifest.tempfile.path
    # copy manifest temp file to application tmp dir (for debugging if needed)
    copied_manifest_path = Rails.root.join(Dir.tmpdir, 'manifest_' + File.basename(input_path)).to_s
    FileUtils.copy(input_path, copied_manifest_path)
    input_path = copied_manifest_path

    media_path = user_share_full_path
    admin_user = User.batch_user
    depositor = current_user
    organization_id = request.params["organization_id"]
    device_id = request.params["batch_submission"]["device_id"]
    if request.params["batch_submission"]["on_behalf_of"].present?
      on_behalf_of = User.where(ms_id: request.params["batch_submission"]["on_behalf_of"]).first
    else
      on_behalf_of = nil
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
    modality = request.params["batch_submission"]["modality"]
    owner = request.params.dig("media","owner") || on_behalf_of&.ms_id || depositor.ms_id
    media_ownership_fields = request.params["batch_submission"]["media"]
    media_ownership_fields["owner"] = owner
    media_ownership_fields["organization_transfer_on_publish"] = true if ( organization_media_transfer == :publication )
    @manifest_object = BatchSubmissionTools::Ms2Batch::Manifest.new(
      input_path:input_path,
      input_data:nil,
      media_path:media_path,
      admin_user:admin_user,
      depositor:depositor,
      owner:owner,
      on_behalf_of:on_behalf_of,
      collection_ids:collection_ids,
      fund_code_id:fund_code_id,
      organization_id:organization_id,
      organization_transfer_immediately:( organization_media_transfer == :immediate ),
      device_id:device_id,
      media_ownership_fields:media_ownership_fields,
      modality:modality).to_h
  end

  def ingest
    redirect_to ({:action=>'index'}), :notice => "Your submission job has started.  You can check the job status below."
  end

  def start_ingest_job
    background_job = BackgroundJob.create!({
      data: @request_manifest_object,
      user_id: current_user.user_key,
      created_objects: {}
    })
    job = ::BatchSubmissionJobs::Ms2Batch::ControlJob.perform_later(background_job.id, current_user)
    background_job.update!({
      job_id: job.job_id,
      job_class: job.class.to_s,
      status: job.status.status.to_s,
    })

    # rename the manifest tmp file with job id for locating easier
    if (manifest_tmp_file = @request_manifest_object["summary"]["manifest_tmp_file"]).present?
      if File.exist?(manifest_tmp_file)
        new_file = Rails.root.join(Dir.tmpdir, 'manifest_' + job.job_id + File.extname(manifest_tmp_file)).to_s
        File.rename(manifest_tmp_file, new_file)
      end
    end
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
          File.join(Hyrax.config.sftp_share_root, user_set_path, '/')
        elsif Dir.exist?(user_set_path)
          unless user_set_path.match(/^\//)
            # if relative path, change it to absolute
            File.join(Rails.root, user_set_path, '/')
          else
            File.join(user_set_path, '/')
          end
        else
          "NOT_FOUND"
        end
      end
    end

    def check_batch_submission_access
      if !current_user.batch_submission_contributor? && !current_user.admin?
        render 'not_allowed', locals: { message: 'Sorry, you do not have permission.', show_dashboard_link: false }
      elsif user_share_full_path == "NOT_FOUND"
        render 'not_allowed', locals: { message: 'Your SFTP share is not connected.  Please check your user profile.', show_dashboard_link: false }
      end
    end

    def check_new_submit_allowed
      if !current_user.can_submit_new_batch_submission?
        render 'not_allowed', locals: { message: 'Sorry, you currently have a batch submission job running. ', show_dashboard_link: true }
      end
    end

    def check_request_manifest_object
      @request_manifest_object = JSON.parse(request.params["manifest_object"])
      if !@request_manifest_object.present?
        flash[:error] = 'The manifest is missing.  Please submit the batch submission form again.'
        return redirect_to main_app.new_batch_submission_path
      end
    end

    def check_dup_job
      request_summary = @request_manifest_object["summary"].except("manifest_tmp_file")
      matching_background_job = BackgroundJob.where(
        "(data->'summary') - 'manifest_tmp_file' = ?::jsonb",
        request_summary.to_json
      ).first

      if (
        matching_background_job.present? &&
        (dup_job_id = dup_job_found("BatchSubmissionJobs::Ms2Batch::ControlJob", matching_background_job.id)).present?
      )
        Rails.logger.debug "iN BatchSubmissionsController: Not starting ControlJob because duplicate job found: #{dup_job_id}"
        flash[:error] = "Batch submission job did not start because a duplicate job has been found: #{dup_job_id}  Please contact MorphoSource team if needed."
        return redirect_to main_app.new_batch_submission_path
      end
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
