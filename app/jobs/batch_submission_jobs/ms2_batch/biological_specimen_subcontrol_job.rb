class BatchSubmissionJobs::Ms2Batch::BiologicalSpecimenSubcontrolJob < Morphosource::ApplicationJobWithStatus
  include BatchSubmissionTools::Ms2Batch::BatchSubmission
  attr_accessor :background_job_id

  queue_as Hyrax.config.ingest_queue_name

  def perform(background_job_id, control_job_id)
    # Step 0. Initial preparation
    @background_job_id = background_job_id

    # Submit jobs for new works to be created
    background_job_manifest['biological_specimen_ingests'].each_with_index do |b, index|
      next if b['id'].present?

      taxonomy_ids = taxonomy_ids_for_ingest(index)
      b['attrs'].merge!('taxonomy_id' => taxonomy_ids)

      b['job_id'] = ::BatchObjectImportJob.perform_later(
        'BiologicalSpecimen',
        b['attrs'].symbolize_keys,
        nil,
        false
      ).job_id
    end

    # Update manifest so job IDs get saved
    update_background_job_manifest('biological_specimen_ingests', background_job_manifest['biological_specimen_ingests'])

    # Monitor jobs
    sleep(30.seconds) until monitor_works_to_be_created

    # Report errors
    exceptions = []
    background_job_manifest['biological_specimen_ingests'].each_with_index do |b, index|
      if b['job_exception'].present?
        exceptions << "Biological Specimen ingest #{index} failed. Exception: \"#{b['job_exception']}\". Supplied attributes were: \"#{b['attrs']}\""
      end
    end
    if exceptions.present?
      raise "One or more biological specimen ingests failed. #{exceptions.join('; ')}"
    end
  end

  def taxonomy_ids_for_ingest(index)
    row_index = background_job_manifest['rows_to_bso']
      .find { |k, v| v == index }
      .first

    taxonomy_ingests = ( background_job_manifest['rows_to_taxonomy'][row_index] || [] )
      .map { |t_idx| background_job_manifest['taxonomy_ingests'][t_idx] }

    if taxonomy_ingests.all? { |t| t['id'].present? }
      return taxonomy_ingests.map { |t| t['id'] }
    else
      raise "Some taxonomies to be ingested do not have IDs. Taxonomies: #{taxonomy_ingests.join('; ')}"
    end
  end

  def monitor_works_to_be_created
    jobs_complete = true

    background_job_manifest['biological_specimen_ingests'].each do |i|
      job_id = i['job_id']
      next if !job_id.present?

      # check job status
      job_status = ActiveJob::Status.get(job_id)
      i['job_status'] = job_status[:status].to_s
      if job_status[:status] == :queued || job_status[:status] == :working
        jobs_complete = false
      elsif job_status[:status] == :failed
        i['job_exception'] = "Job BatchObjectImportJob with ID #{job_id} failed. Exception: #{job_status[:exception].to_s}"
      elsif job_status[:status] == :completed
        if job_status[:id].present?
          i['id'] = job_status[:id]
        else
          i['job_exception'] = "Job BatchObjectImportJob with ID #{job_id} completed successfully, but produced no work ID."
        end
      else
        i['job_exception'] = "Job BatchObjectImportJob with ID #{job_id} produced unexpected status: #{job_status[:status].to_s}"
      end
    end

    # Update manifest so latest status and work IDs are saved
    update_background_job_manifest('biological_specimen_ingests', background_job_manifest['biological_specimen_ingests'])

    return jobs_complete
  end
end