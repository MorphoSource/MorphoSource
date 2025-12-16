module Morphosource
  ##
  # Create and execute multiple batch submission jobs, one per combination of organization and device
  #
  # Requires a multi-batch spreadsheet file where each row represents a media. Each row must also
  # contain information listing the object organization, imaging device, and device modality specific
  # to the individual media. Normally batch submissions must include only media from one organization
  # and one device. This service allows devs to create experimental batch submissions for collections
  # of media from multiple organizations and devices. Running this service will create one
  # BackgroundJob object for each submission associated with a triggering user, but it will not
  # launch any of those jobs. Each BackgroundJob sequence must be triggered separately.
  #
  # @example
  #   service = Morphosource::MultiBatchSubmissionService.new(xlsx_file_path: 'test.xlsx', user: User.last)
  #   background_jobs = service.create_submissions
  #   service.execute_background_job(background_jobs.first)
  class MultiBatchSubmissionService
    include BatchSubmissionTools::Ms2Batch::BatchSubmission
    attr_reader :xlsx_file_path, :user, :xlsx_file, :ownership_options

    def initialize(xlsx_file_path:, user:, ownership_options: {})
      @xlsx_file_path = xlsx_file_path
      @user = user
      @ownership_options = ownership_options || {}
    end

    ##
    # Create but not launch BackgroundJob objects, one per media collection from each
    # organization and device combination. BackgroundJobs should be launched later separately to
    # allow for testing and monitoring.
    #
    # @param [String] xlsx_file_path Path to multi batch excel spreadsheet file
    # @param [User] user User managing and triggering background jobs
    #
    # @return [Array<BackgroundJob>] Background jobs, one for each org/device combo, saved but not launched
    def create_submissions(xlsx_file_path: @xlsx_file_path, user: @user)
      @xlsx_file_path = xlsx_file_path
      @user = user
      @xlsx_file = Roo::Excelx.new(xlsx_file_path)

      batch_file_validity = BatchSubmissionTools::Ms2Batch::BatchFileValidator.new(
        xlsx_file: xlsx_file,
        user: user
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

      log_messages("Warnings", validity_data[:warn_messages])
      log_messages("Errors", validity_data[:error_messages])

      if validity_status == "success"
        create_background_jobs
      else
        raise "Batch file was invalid. See validity results: #{validity_data}"
      end
    end

    def xlsx_to_collections
      headers = xlsx_file.row(7).drop(2)
      grouped_rows = Hash.new { |h, k| h[k] = [] }

      row_index = 8 # media list starts at row 8 (1-indexed in Excel)
      xlsx_file.each_row_streaming(offset: 7, pad_cells: true) do |row|
        data_row = row.drop(2)
        # Skip empty rows
        next if data_row.all? { |c| c.nil? || c.value.to_s.strip.empty? }

        device_id = pad_id(xlsx_file.cell(row_index, 86))
        organization_id = pad_id(xlsx_file.cell(row_index, 88))
        combo_key = [organization_id, device_id]

        grouped_rows[combo_key] << build_row_attributes(headers, data_row)
        row_index += 1
      end

      return grouped_rows
        .sort_by { |(org_id, device_id), _| [org_id.to_s, device_id.to_s] }
        .map do |(org_id, device_id), rows|
          parsed_rows, _ = parse_input_rows(rows)
          { { organization_id: org_id, device_id: device_id } => parsed_rows }
        end 
    end

    def create_background_jobs
      batch_file_data = xlsx_to_collections
      return [] unless batch_file_data.present?

      batch_file_data.flat_map do |combo|
        combo.map do |org_device_group, media_rows|
          manifest = build_manifest(org_device_group, media_rows)
          create_background_job(manifest.to_h)
        end
      end
    end

    def create_background_job(manifest)
      background_job = BackgroundJob.create!({
        data: manifest,
        user_id: user.user_key,
        created_objects: {}
      })
    end

    ##
    # Trigger previously saved BackgroundJob batch submission. Will launch a background batch
    # submission control job using data from saved BackgroundJob, which will in turn launch other
    # secondary and tertiary jobs to carry out submission.
    #
    # @param [BackgroundJob] background_job BackgroundJob with data necessary for running batch submission.
    #
    # @return [BackgroundJob] BackgroundJob object with queued job details and status.
    def execute_background_job(background_job)
      job = ::BatchSubmissionJobs::Ms2Batch::ControlJob.perform_later(background_job.id, background_job.user)
      background_job.update!({
        job_id: job.job_id,
        job_class: job.class.to_s,
        status: job.status.status.to_s,
      })

      # If there is a manifest tmp file, rename to job id to locate easier
      if (manifest_tmp_file = background_job.data["summary"]["manifest_tmp_file"]).present?
        if File.exist?(manifest_tmp_file)
          new_file = Rails.root.join(Dir.tmpdir, 'manifest_' + job.job_id + File.extname(manifest_tmp_file)).to_s
          File.rename(manifest_tmp_file, new_file)
        end
      end

      return background_job
    end

    private

    def build_manifest(org_device_group, media_rows)
      manifest_args = manifest_arguments(org_device_group, media_rows)
      puts "media_rows (#{media_rows.count}) : #{media_rows.inspect[0,80]...}"
      manifest_args.each do |key, value|
        puts "#{key}: #{value.inspect[0,80]...}"
      end
      BatchSubmissionTools::Ms2Batch::Manifest.new(**manifest_args)
    end

    def manifest_arguments(org_device_group, media_rows)
      media_path = user_share_full_path
      raise "Media path directory not found for #{user.user_key}" if media_path == "NOT_FOUND"

      organization_id = org_device_group[:organization_id]
      device_id = org_device_group[:device_id]
      modality = media_rows.first&.dig(:experimental, :device_modality)&.first
      ownership_fields = media_ownership_fields(organization_id)
byebug
      {
        input_path: nil,
        input_data: media_rows,
        media_path: media_path,
        admin_user: User.batch_user,
        depositor: user,
        owner: user.ms_id,
        on_behalf_of: nil, # ?
        organization_id: organization_id,
        organization_transfer_immediately: false, # ?
        device_id: device_id,
        collection_ids: [],
        fund_code_id: nil, # ?
        media_ownership_fields: ownership_fields,
        modality: modality
      }
    end

    def media_ownership_fields(org_id)
      # Prefer organization settings, then caller-provided ownership_options for that organization, then fall back to defaults.
      org = OrganizationCollection.find(org_id)
      org_fields = {
        "visibility" => Array(org.download_permission).first,
        "download_reviewer" => Array(org.download_reviewer),
        "rights_holder" => Array(org.rights_holder),
        "rights_statement" => Array(org.rights_statement).first,
        "license" => Array(org.license).first,
        "morphosource_use_agreement_type" => Array(org.morphosource_use_agreement_type).first,
        "permits_commercial_use" => Array(org.permits_commercial_use).first,
        "permits_3d_use" => Array(org.permits_3d_use).first,
        "required_archival_of_published_derivatives" => Array(org.required_archival_of_published_derivatives).first,
        "publisher" => Array(org.publisher),
        "preview_mode" => Array(org.preview_mode).first,
        "agreement_uri" => Array(org.agreement_uri).first,
        "member_of_collection_ids" => Array(org.member_of_collection_ids),
        "owner" => Array(org.depositor).first,
        "organization_transfer_on_publish" => false # ?
      }

      defaults = default_ownership_fields
      org_overrides = ownership_options_for(org_id)

      default.keys.each_with_object({}) do |key, compiled|
        org_value = org_fields[key]
        ownership_value = fetch_option_value(org_overrides, key)
        compiled[key] =
          if ownership_value_available?(org_value)
            org_value
          elsif ownership_value_available?(ownership_value)
            ownership_value
          else
            defaults[key]
          end
      end
    end

    def default_ownership_fields
      {
        "visibility"=>"restricted", 
        "download_reviewer"=>user.ms_id, 
        "rights_holder"=>[""], 
        "rights_statement"=>"", 
        "license"=>"", 
        "morphosource_use_agreement_type"=>"Standard", 
        "permits_commercial_use"=>"CommercialUseNotPermitted", 
        "permits_3d_use"=>"3DPrintingLimited", 
        "required_archival_of_published_derivatives"=>"OnMorphoSource", 
        "funding"=>[""], 
        "publisher"=>[""], 
        "cite_as"=>"", 
        "preview_mode"=>"Interactive/Embeddable", 
        "agreement_uri"=>"", 
        "member_of_collection_ids"=>"", 
        "owner"=>user.ms_id,
        "organization_transfer_on_publish"=>false
      }
    end

    def ownership_value_available?(value)
      return true if value == false

      value.present?
    end

    def ownership_options_for(org_id)
      return {} if ownership_options.blank?

      ownership_options[org_id] || ownership_options[org_id.to_s] || ownership_options[org_id.to_sym] || {}
    end

    def fetch_option_value(options_hash, key)
      options_hash[key] || options_hash[key.to_s] || options_hash[key.to_sym]
    end

    def user_share_full_path
      @user_share_full_path ||= begin
        user_set_path = user.sftp_share
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

    def log_messages(label, messages)
      return if messages.blank?

      puts "#{label}:"
      messages.each do |row, msgs|
        next if msgs.blank?
        Array(msgs).reject(&:blank?).each do |msg|
          puts "  Row #{row}: #{msg}"
        end
      end
    end

    def build_row_attributes(headers, data_row)
      {}.tap do |processed|
        headers.each_with_index do |header, index|
          val = data_row[index]&.value
          processed[header.to_sym] ||= []
          processed[header.to_sym] += val.present? ? val.to_s.split(';').map(&:strip) : []
        end
      end
    end

    def pad_id(val)
      return nil unless val.present?

      str = val.is_a?(Numeric) ? val.to_i.to_s : val.to_s
      str.length < 9 ? ("0" * (9 - str.length)) + str : str
    end
  end
end
