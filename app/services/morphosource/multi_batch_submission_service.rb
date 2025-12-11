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
    attr_reader :xlsx_file_path, :user, :xlsx_file

    def initialize(xlsx_file_path:, user:)
      @xlsx_file_path = xlsx_file_path
      @user = user
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

    def create_background_jobs



    end

    def create_background_job(manifest)
      background_job = BackgroundJob.create!({
        data: manifest,
        user_id: user.user_key,
        created_objects: {}
      })
    end

    private

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
  end
end
