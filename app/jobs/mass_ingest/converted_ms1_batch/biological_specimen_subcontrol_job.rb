class MassIngest::ConvertedMs1Batch::MassIngestControlJob < ApplicationJob
  attr_accessor :manifest

  queue_as Hyrax.config.ingest_queue_name

  def perform(manifest)
    # Step 0. Initial preparation
    status.update(manifest: manifest)
    @manifest = manifest

    # Submit jobs for new works to be created
    @manifest[:biological_specimen_ingests].each_with_index do |b, index|
      next unless !b[:id].present? # new work to be created

      row_index = @manifest[:rows_to_bso]
        .find { |k, v| v == index }
        .first
      taxonomy_ingests = @manifest[:rows_to_taxonomy][row_index]
        .map { |t_idx| @manifest[:taxonomy_ingests][t_idx] }

      if taxonomy_ingests.all? { |t| t[:id].present? }
        b[:attrs].merge!(taxonomy_id: taxonomy_ingests.map { |t| t[:id] } )
      else
        raise "Some taxonomies to be ingested do not have IDs. Taxonomies: #{taxonomy_ingests.join('; ')}"
      end

      b[:job] = ::BatchObjectImportJob.perform_later(BiologicalSpecimen, b[:attrs], nil, false)
    end

    # Monitor jobs
    sleep(1.minute) until monitor_works_to_be_created

    # Finish and report
    status.update(manifest: @manifest)
    if @manifest[:biological_specimen_ingests].any? { |b| b[:job_exception].present? }
      exceptions = []
      @manifest[:biological_specimen_ingests].each_with_index do |b, index|
        if b[:job_exception].present?
          exceptions << "Biological Specimen ingest #{index} failed. Exception: \"#{b[:job_exception]}\". Supplied attributes were: \"#{b[:attrs]}\""
        end
      end
      raise "One or more biological specimen ingests failed. #{exceptions.join('; ')}"
    end
  end

  def monitor_works_to_be_created
    jobs_complete = true

    @manifest[:biological_specimen_ingests].each do |i|
      next unless (job = i[:job]).present?

      status = ActiveJob::Status.get(i[:job])
      i[:job_status] = status[:status]
      if status[:status] == :queued || status[:status] == :working
        jobs_complete = false
      elsif status[:status] == :failed
        i[:job_exception] = "Job #{job.class} failed. Exception: #{status[:exception]}"
      elsif status[:status] == :completed
        if status[:id].present?
          i[:id] = status[:id]
        else
          i[:job_exception] = "Job #{job.class} completed successfully, but produced no work ID."
        end
      else
        i[:job_exception] = "Job #{job.class} produced unexpected status: #{status[:status]}"
      end
    end

    return jobs_complete
  end
end