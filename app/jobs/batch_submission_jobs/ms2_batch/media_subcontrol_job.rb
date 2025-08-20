class BatchSubmissionJobs::Ms2Batch::MediaSubcontrolJob < Morphosource::ApplicationJobWithStatus
  include BatchSubmissionTools::Ms2Batch::BatchSubmission
  attr_accessor :background_job_id, :control_job_id

  queue_as Hyrax.config.ingest_queue_name

  def perform(background_job_id, control_job_id)
    # Step 0. Initial preparation
    @background_job_id = background_job_id
    @control_job_id = control_job_id

    # Submit jobs for new works to be created
    background_job_manifest['media_ie_pe_ingests'].each_with_index do |i, ingest_index|
      ensure_imaging_event_present(i)
      ensure_single_parent(i)

      bso = bso_from_ingest(i)
      i['physical_object_id'] = pad(bso['id'])

      target_parent_id = check_and_wait_for_parent_media(i)

      i['job_id'] = BatchSubmissionJobs::Ms2Batch::MediaIePeIngestJob.perform_later(
        background_job_id,
        i,
        background_job_manifest['collection_ids'] || [],
        background_job_manifest['fund_code_id'] || nil,
        background_job_manifest['organization_transfer_immediately'] || false,
        target_parent_id
      ).job_id
    end

    # Update manifest so job IDs and physical object IDs get saved
    update_background_job_manifest('media_ie_pe_ingests', background_job_manifest['media_ie_pe_ingests'])

    # Monitor jobs
    sleep(30.seconds) until monitor_ingest_jobs

    # Report errors
    exceptions = []
    background_job_manifest['media_ie_pe_ingests'].each_with_index do |i, index|
      if i['job_exception'].present?
        exceptions << "Media ingest #{index} failed. Exception: \"#{i['job_exception']}\"."
      end
    end
    if exceptions.present?
      exception_message = "One or more media ingests failed. #{exceptions.join('; ')}"
      update_background_job('failed', exception_message)
      raise exception_message
    end
  end

  def ensure_imaging_event_present(ingest)
    if !ingest['imaging_event']&.first.present?
      raise "Imaging event not present for ingest. Ingest: #{ingest}"
    end
  end

  def ensure_single_parent(ingest)
    if ingest['parent'].present? && ingest['parent'].count > 1
      raise "Only one parent should be present for media ingestion, but multiple are present. Parents: #{ingest['parent']}"
    end
  end

  # Find the BSO associated with media
  def bso_from_ingest(ingest)
    ie_row_index = ingest['imaging_event'].first[0]
    bso = background_job_manifest['biological_specimen_ingests'][background_job_manifest['rows_to_bso'][ie_row_index]]

    if !bso.present?
      raise "Media ingest requires a biological specimen present. Provided BSO: #{bso}"
    elsif !bso['id'].present?
      raise "A supposedly ingested biological specimen does not have ID. Provided BSO: #{bso}"
    end

    return bso
  end

  def check_and_wait_for_parent_media(ingest)
    # check if the ingest depends on a derived parent
    derived_parent_file = ""
    target_parent_id = nil

    ingest['children'].each do |idx, child|
      if child['media'].present?
        derived_parent_file = child['media']['derived_parent_file']
        break if derived_parent_file.present?
      end
    end

    if derived_parent_file.present?
      Rails.logger.debug "iN MediaSubcontrolJob: waiting for parent media creation: #{derived_parent_file}"
      wait_started = Time.now
      sleep(30.seconds) until (target_parent_id = created_parent_id(derived_parent_file, wait_started)).present?
      Rails.logger.debug "iN MediaSubcontrolJob: parent media found: #{derived_parent_file} > #{target_parent_id}"
    end
  end

  def created_parent_id(parent_file, wait_started)
    duration = Time.now - wait_started
    Rails.logger.debug "iN created_parent_id: looking for #{parent_file} in job #{background_job_id}... (#{duration} seconds)"
    if background_job.created_objects[parent_file].present?
      return background_job.created_objects[parent_file]
    else
      if duration > 3600 # 1 hr
        raise "Timeout waiting for parent file #{parent_file} to be created in job #{background_job_id}"
      else
        return nil
      end
    end
  end

  def monitor_ingest_jobs
    jobs_complete = true

    background_job_manifest['media_ie_pe_ingests'].each do |i|
      job_id = i['job_id']
      next if !job_id.present?

      # check job status
      job_status = ActiveJob::Status.get(job_id)
      i['job_status'] = job_status[:status].to_s
      if job_status[:status] == :queued || job_status[:status] == :working
        jobs_complete = false
      elsif job_status[:status] == :failed
        i['job_exception'] = "Job MediaIePeIngestJob with ID #{job_id} failed. Exception: #{job_status[:exception].to_s}"
      elsif job_status[:status] == :completed
        next
      else
        i['job_exception'] = "Job MediaIePeIngestJob with ID #{job_id} produced unexpected status: #{job_status[:status].to_s}"
      end
    end

    # Update manifest so latest status is saved
    update_background_job_manifest('media_ie_pe_ingests', background_job_manifest['media_ie_pe_ingests'])

    return jobs_complete
  end

  def update_background_job(status_str=nil, exceptions=nil)
    background_job.update_status(status_str, exceptions)
  end
end
