class BatchSubmissionJobs::Ms2Batch::ControlJob < Morphosource::ApplicationJobWithStatus
  attr_accessor :manifest, :main_job_id

  queue_as Hyrax.config.batch_submission_queue_name

  def perform(manifest)
    begin
      # Step 0. Initial preparation
      status.update(manifest: manifest)
      @manifest = manifest
      @main_job_id = status.job_id
      update_main_job

      sub_jobs.each do |job_class|
        Rails.logger.debug "iN ControlJob: sending main_job_id  #{@main_job_id} to sub_job  " 
        job = job_class.send :perform_later, @manifest, @main_job_id
        sleep(1.minute) until monitor_status(job)
        progress.increment
      end
    rescue StandardError => e
      # debug: check exception here if stopped
      #byebug
      status.update(status: :failed)
      update_main_job(exceptions: e.message)
      status.update(manifest: @manifest, exception: e.message)      
    ensure
      status.update(manifest: @manifest)
    end

byebug
    sleep(1.minute) until monitor_main_status

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

  def update_main_job(exceptions=nil)
    # might need to update status to fail if exceptions are found?
byebug
    main_job.update_status(status: status.status.to_s, exceptions: exceptions)
  end

  def monitor_main_status
    if status.status == :queued || status.status == :working
byebug
      update_main_job
      return false
    elsif status.status == :completed 
byebug
      update_main_job
      return true
    elsif status.status == :failed
byebug
      update_main_job(status.exception)
      return true
    else
byebug
      Rails.logger.debug "iN ControlJob: unknown status #{status.status} " 
      update_main_job
      return true
    end
  end

  def monitor_status(job)
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