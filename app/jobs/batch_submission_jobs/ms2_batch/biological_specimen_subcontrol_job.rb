class BatchSubmissionJobs::Ms2Batch::BiologicalSpecimenSubcontrolJob < Morphosource::ApplicationJobWithStatus
  include BatchSubmissionTools::Ms2Batch::BatchSubmission
  attr_accessor :background_job_id

  queue_as Hyrax.config.ingest_queue_name

  def perform(background_job_id, control_job_id)
    # Step 0. Initial preparation
    @background_job_id = background_job_id

    # Submit jobs for new works to be created
    background_job_manifest['biological_specimen_ingests'].each_with_index do |b, index|
      co_key = "bso_#{index}"

      # Crash recovery: object created in prior run but manifest id not written
      if !b['id'].present? && background_job.created_objects[co_key].present? && object_exists?(background_job.created_objects[co_key])
        b['id'] = background_job.created_objects[co_key]
        update_background_job_manifest('biological_specimen_ingests', background_job_manifest['biological_specimen_ingests'])
      end

      next if object_exists?(b['id'])

      b['job_exception'] = nil
      b['job_status'] = nil
      taxonomy_ids = taxonomy_ids_for_ingest(index)
      b['attrs'].merge!('taxonomy_id' => taxonomy_ids)

      b['job_id'] = ::BatchObjectImportJob.perform_later(
        'BiologicalSpecimen',
        b['attrs'].symbolize_keys,
        nil,
        false,
        @background_job_id,
        co_key
      ).job_id
    end

    # Update manifest so job IDs get saved
    update_background_job_manifest('biological_specimen_ingests', background_job_manifest['biological_specimen_ingests'])

    # Monitor jobs
    sleep(30.seconds) until monitor_works_to_be_created

    # Report errors
    exceptions = []
    background_job_manifest['biological_specimen_ingests'].each_with_index do |b, index|
      next if object_exists?(b['id'])
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
      next if object_exists?(i['id'])

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

  def object_exists?(id)
    return false unless id.present?
    @object_works_cache ||= {}
    @object_works_cache[id] = BiologicalSpecimen.exists?(id) unless @object_works_cache.key?(id)
    @object_works_cache[id]
  end
end
