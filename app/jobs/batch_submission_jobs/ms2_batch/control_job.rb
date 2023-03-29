class BatchSubmissionJobs::Ms2Batch::ControlJob < Morphosource::ApplicationJobWithStatus
  include BatchSubmissionTools::Ms2Batch::BatchSubmissionHelper  
  attr_accessor :manifest, :main_job_id

  queue_as Hyrax.config.batch_submission_queue_name

  def perform(manifest, user)
    # Step 0. Initial preparation
    status.update(manifest: manifest)
    @manifest = manifest
    @main_job_id = status.job_id

    if (dup_job_id = dup_job_found("BatchSubmissionJobs::Ms2Batch::ControlJob", manifest, status.job_id)).present?
      Rails.logger.debug "iN ControlJob #{@main_job_id}: Not starting ControlJob because duplicate job found: #{dup_job_id}"
      error_msg = "Batch submission job did not start because a duplicate job has been found: #{dup_job_id}"
      status.update(status: :failed)
      update_main_job("failed", error_msg)
      status.update(manifest: manifest, exception: error_msg)
      return nil
    end

    begin      
      update_main_job(status.status.to_s, nil)
      exception_caught = false
 
      sub_jobs.each do |job_class|
        Rails.logger.debug "iN ControlJob #{@main_job_id}: sending to sub_job  " 
        job = job_class.send :perform_later, @manifest, @main_job_id
        sleep(30.seconds) until monitor_subjob_status(job)
        progress.increment
      end
    rescue StandardError => e
      Rails.logger.debug "iN ControlJob #{@main_job_id}: Exception caught #{e.message} "
      status.update(status: :failed)
      update_main_job("failed", e.message)
      notify_user(user, "failed", @main_job_id)
      status.update(manifest: @manifest, exception: e.message)
      exception_caught = true
    ensure
      status.update(manifest: @manifest)
    end
    # at this point, all subjobs are either :completed, 
    # unless exception was raised and caught above
    unless exception_caught    
      update_main_job("completed") 
      notify_user(user, "completed", @main_job_id)
    end
  end

  def sub_jobs
    [
      BatchSubmissionJobs::Ms2Batch::TaxonomySubcontrolJob,
      BatchSubmissionJobs::Ms2Batch::BiologicalSpecimenSubcontrolJob,
      BatchSubmissionJobs::Ms2Batch::MediaSubcontrolJob
    ]
  end

  def main_job
    BackgroundJob.where(main_job_id: main_job_id).first
  end

  def update_main_job(status_str=nil, exceptions=nil)
    unless status_str.present?
      status_str = status.status.to_s 
    end
    main_job.update_status(status_str, exceptions)
  end

  def monitor_subjob_status(job)
    #return true if job == true # it returns true if perform_now (for testing)
    job_status = ActiveJob::Status.get(job)

    # update manifest
    new_manifest = job_status[:manifest]
    if new_manifest.present? && new_manifest.is_a?(Hash)
      status.update(manifest: new_manifest)
      @manifest = new_manifest
    end

    # check job status
    if job_status[:status] == :failed
      delete_created_works
      exception = "Job #{job.class} failed. Exception: #{job_status[:exception].to_s}"
      raise exception
    elsif job_status[:status] == :queued || job_status[:status] == :working
      return false
    elsif job_status[:status] == :completed
      return true
    else
      delete_created_works
      exception = "Job #{job.class} produced unexpected status: #{job_status[:status].to_s}"
      raise exception
    end
    update_main_job
  end

  # if ingest fails, need to delete mid-stream works
  def delete_created_works
    status.update(work_deletion: :working)

    related_ids = []
    
    main_job.created_objects.each do |key, id|
      related_ids.concat delete_work_if_needed(id)
    end

    final_related_ids = related_ids
      .uniq
      .select { |id| id if ActiveFedora::Base.exists?(id) }
      .compact
    UpdateRelatedWorksIndexJob.perform_later(final_related_ids)

    # clear the created_objects list
    main_job.clear_created_objects

    status.update(work_deletion: :completed)
  end

  def delete_work_if_needed(id)
    related_work_ids = []
    if ActiveFedora::Base.exists?(id)
      work = ActiveFedora::Base.find(id)
      case work.class
      when ImagingEvent
        related_work_ids.concat(work.objects) if work.objects.present?
      when ProcessingEvent
        related_work_ids << work.imaging_event if work.imaging_event.present?
      when Media
        related_work_ids << work.processing_event if work.processing_event.present?
      end
      work.destroy
    end

    return related_work_ids
  end

end