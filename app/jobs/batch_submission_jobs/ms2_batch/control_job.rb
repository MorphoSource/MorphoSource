class BatchSubmissionJobs::Ms2Batch::ControlJob < Morphosource::ApplicationJobWithStatus
  attr_accessor :manifest, :main_job_id

  queue_as Hyrax.config.batch_submission_queue_name

  def perform(manifest)

# todo: put back the error catching code after testing
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
      status.update(manifest: @manifest, exception: e.message)      
    ensure
      update_main_job
      status.update(manifest: @manifest)
    end
    update_main_job
  end

  def sub_jobs
    [
      BatchSubmissionJobs::Ms2Batch::TaxonomySubcontrolJob,
      BatchSubmissionJobs::Ms2Batch::BiologicalSpecimenSubcontrolJob,
      BatchSubmissionJobs::Ms2Batch::MediaSubcontrolJob
    ]
  end

  def main_job
    BackgroundJob.where(job_id: main_job_id).first
  end

  def update_main_job(exception=nil)
    main_job.update_status(status.status.to_s, exception)
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
      update_main_job(exception)
      raise exception
    elsif job_status[:status] == :queued || job_status[:status] == :working
      return false
    elsif job_status[:status] == :completed
      return true
    else
      delete_created_works
      exception = "Job #{job.class} produced unexpected status: #{job_status[:status].to_s}"
      update_main_job(exception)
      raise exception
    end
    update_main_job
  end

  # if ingest fails, need to delete mid-stream works
  def delete_created_works
    status.update(work_deletion: :working)

    related_ids = []
    @manifest['media_ie_pe_ingests'].each do |i|
      i['children'].each do |k, combined_pe_media|
        related_ids.concat delete_work_if_needed(combined_pe_media['media'])
        related_ids.concat delete_work_if_needed(combined_pe_media['pe'])
      end

      i['parent'].each do |k, combined_pe_media|
        related_ids.concat delete_work_if_needed(combined_pe_media['media'])
        related_ids.concat delete_work_if_needed(combined_pe_media['pe'])
      end

      related_ids.concat delete_work_if_needed(i['imaging_event'].values.first)
    end

    @manifest['biological_specimen_ingests'].each do |i|
      related_ids.concat delete_work_if_needed(i)
    end

    @manifest['taxonomy_ingests'].each do |i|
      related_ids.concat delete_work_if_needed(i)
    end

    final_related_ids = related_ids
      .uniq
      .select { |id| id if ActiveFedora::Base.exists?(id) }
      .compact
    UpdateRelatedWorksIndexJob.perform_later(final_related_ids)

    status.update(work_deletion: :completed)
  end

  def delete_work_if_needed(i)
    related_work_ids = []

    if i['attrs'].present? && i['id'].present? && ActiveFedora::Base.exists?(i['id'])
      work = ActiveFedora::Base.find(i['id'])
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