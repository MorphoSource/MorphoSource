class BatchSubmissionJobs::Ms2Batch::ControlJob < Morphosource::ApplicationJobWithStatus
  include BatchSubmissionTools::Ms2Batch::BatchSubmission
  attr_accessor :background_job_id, :control_job_id

  queue_as Hyrax.config.batch_submission_queue_name

  def perform(background_job_id, user)
    # Step 0. Initial preparation
    @background_job_id = background_job_id
    @control_job_id = status.job_id

    if (dup_job_id = dup_job_found("BatchSubmissionJobs::Ms2Batch::ControlJob", background_job_id, control_job_id)).present?
      Rails.logger.debug "iN ControlJob #{control_job_id}: Not starting ControlJob because duplicate job found: #{dup_job_id}"
      error_msg = "Batch submission job did not start because a duplicate job has been found: #{dup_job_id}"
      status.update(status: :failed, exception: error_msg)
      update_background_job("failed", error_msg)
      return nil
    end

    begin
      update_background_job(status.status.to_s, nil)
      exception_caught = false

      sub_jobs.each do |job_class|
        Rails.logger.debug "iN ControlJob #{control_job_id}: sending to sub_job"
        job = job_class.send :perform_later, background_job_id, control_job_id
        sleep(30.seconds) until monitor_subjob_status(job)
        progress.increment
      end
    rescue StandardError => e
      Rails.logger.debug "iN ControlJob #{control_job_id}: Exception caught #{e.message} "
      status.update(status: :failed, exception: e.message)
      update_background_job("failed", e.message)
      notify_user(user, "failed", control_job_id)
      exception_caught = true
    end
    # at this point, all subjobs are :completed
    # unless exception was raised and caught above
    unless exception_caught
      update_background_job("completed")
      notify_user(user, "completed", control_job_id)
    end
  end

  def sub_jobs
    [
      BatchSubmissionJobs::Ms2Batch::TaxonomySubcontrolJob,
      BatchSubmissionJobs::Ms2Batch::BiologicalSpecimenSubcontrolJob,
      BatchSubmissionJobs::Ms2Batch::MediaSubcontrolJob
    ]
  end

  def update_background_job(status_str=nil, exceptions=nil)
    unless status_str.present?
      status_str = status.status.to_s
    end
    background_job.update_status(status_str, exceptions)
  end

  def monitor_subjob_status(job)
    #return true if job == true # it returns true if perform_now (for testing)
    job_status = ActiveJob::Status.get(job)

    # check job status
    if job_status[:status] == :failed
      exception = "Job #{job.class} failed. Exception: #{job_status[:exception].to_s}"
      raise exception
    elsif job_status[:status] == :queued || job_status[:status] == :working
      return false
    elsif job_status[:status] == :completed
      return true
    else
      exception = "Job #{job.class} produced unexpected status: #{job_status[:status].to_s}"
      raise exception
    end
    update_background_job
  end

end