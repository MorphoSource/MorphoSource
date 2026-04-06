class BatchSubmissionJobs::Ms2Batch::TaxonomySubcontrolJob < Morphosource::ApplicationJobWithStatus
  include BatchSubmissionTools::Ms2Batch::BatchSubmission
  attr_accessor :background_job_id

  queue_as Hyrax.config.ingest_queue_name

  def perform(background_job_id, control_job_id)
    # Step 0. Initial preparation
    @background_job_id = background_job_id

    # Submit jobs for new works to be created
    background_job_manifest['taxonomy_ingests'].each_with_index do |t, index|
      co_key = "taxonomy_#{index}"

      # Crash recovery: object created in prior run but manifest id not written
      if !t['id'].present? && background_job.created_objects[co_key].present?
        t['id'] = background_job.created_objects[co_key]
        update_background_job_manifest('taxonomy_ingests', background_job_manifest['taxonomy_ingests'])
      end

      next if t['id'].present?

      t['job_exception'] = nil
      t['job_status'] = nil
      t['job_id'] = ::BatchObjectImportJob.perform_later(
        'Taxonomy',
        t['attrs'].symbolize_keys,
        nil,
        false,
        @background_job_id,
        co_key
      ).job_id
    end

    # Update manifest so job IDs get saved
    update_background_job_manifest('taxonomy_ingests', background_job_manifest['taxonomy_ingests'])

    # Monitor jobs
    sleep(30.seconds) until monitor_works_to_be_created

    # Check for exceptions and raise if present
    exceptions = []
    background_job_manifest['taxonomy_ingests'].each_with_index do |t, index|
      next if t['id'].present?
      if t['job_exception'].present?
        exceptions << "Taxonomy ingest #{index} failed. Exception: \"#{t['job_exception']}\". Supplied attributes were: \"#{t['attrs']}\""
      end
    end
    if exceptions.present?
      raise "One or more taxonomy ingests failed. #{exceptions.join('; ')}"
    end
  end

  def monitor_works_to_be_created
    jobs_complete = true

    background_job_manifest['taxonomy_ingests'].each do |t|
      next if t['id'].present?

      job_id = t['job_id']
      next if !job_id.present?

      # check job status
      job_status = ActiveJob::Status.get(job_id)
      t['job_status'] = job_status[:status].to_s
      if job_status[:status] == :queued || job_status[:status] == :working
        jobs_complete = false
      elsif job_status[:status] == :failed
        t['job_exception'] = "Job BatchObjectImportJob with ID #{job_id} failed. Exception: #{job_status[:exception].to_s}"
      elsif job_status[:status] == :completed
        if job_status[:id].present?
          t['id'] = job_status[:id]
        else
          t['job_exception'] = "Job BatchObjectImportJob with ID #{job_id} completed successfully, but produced no work ID."
        end
      else
        t['job_exception'] = "Job BatchObjectImportJob with ID #{job_id} produced unexpected status: #{job_status[:status].to_s}"
      end
    end

    # Update manifest so latest status and work IDs are saved
    update_background_job_manifest('taxonomy_ingests', background_job_manifest['taxonomy_ingests'])

    return jobs_complete
  end
end