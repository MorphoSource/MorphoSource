class BatchSubmissionJobs::Ms2Batch::BiologicalSpecimenSubcontrolJob < Morphosource::ApplicationJobWithStatus
  attr_accessor :manifest

  queue_as Hyrax.config.ingest_queue_name

  def perform(manifest)
    # Step 0. Initial preparation
    status.update(manifest: manifest)
    @manifest = manifest
    # Submit jobs for new works to be created
    @manifest['biological_specimen_ingests'].each_with_index do |b, index|
      next unless !b['id'].present? # new work to be created

      row_index = @manifest['rows_to_bso']
        .find { |k, v| v == index }
        .first

      taxonomy_ingests = (@manifest['rows_to_taxonomy'][row_index] || [])
        .map { |t_idx| @manifest['taxonomy_ingests'][t_idx] }

      if taxonomy_ingests.all? { |t| t['id'].present? }
        b['attrs'].merge!('taxonomy_id' => taxonomy_ingests.map { |t| t['id'] } )
      else
        raise "Some taxonomies to be ingested do not have IDs. Taxonomies: #{taxonomy_ingests.join('; ')}"
      end

      b['job'] = ::BatchObjectImportJob.perform_later('BiologicalSpecimen', b['attrs'].symbolize_keys, nil, false)
    end

    # Monitor jobs
    sleep(1.minute) until monitor_works_to_be_created

    # Report errors
    status.update(manifest: @manifest)
    if @manifest['biological_specimen_ingests'].any? { |b| b['job_exception'].present? }
      exceptions = []
      @manifest['biological_specimen_ingests'].each_with_index do |b, index|
        if b['job_exception'].present?
          exceptions << "Biological Specimen ingest #{index} failed. Exception: \"#{b['job_exception']}\". Supplied attributes were: \"#{b['attrs']}\""
        end
      end
      raise "One or more biological specimen ingests failed. #{exceptions.join('; ')}"
    end

    # Remove BatchObjectImportJobs from manifest
    @manifest['biological_specimen_ingests'].each { |b| b.except!('job') }
    status.update(manifest: @manifest)
  end

  def monitor_works_to_be_created
    jobs_complete = true

    @manifest['biological_specimen_ingests'].each do |i|
      if i['job'] == true # it returns true if perform_now has been called (can be removed later if perform_later is called)
        next
      end

      next unless (job = i['job']).present?

      # check job status
      job_status = ActiveJob::Status.get(i['job'])
      i['job_status'] = job_status[:status].to_s
      if job_status[:status] == :queued || job_status[:status] == :working
        jobs_complete = false
      elsif job_status[:status] == :failed
        i['job_exception'] = "Job #{job.class} failed. Exception: #{job_status[:exception].to_s}"
      elsif job_status[:status] == :completed
        if job_status[:id].present?
          i['id'] = job_status[:id]
        else
          i['job_exception'] = "Job #{job.class} completed successfully, but produced no work ID."
        end
      else
        i['job_exception'] = "Job #{job.class} produced unexpected status: #{job_status[:status].to_s}"
      end

      # update manifest
      status.update(manifest: @manifest)
    end

    return jobs_complete
  end
end