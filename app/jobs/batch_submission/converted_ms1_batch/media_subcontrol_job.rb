class BatchSubmission::ConvertedMs1Batch::MediaSubcontrolJob < ApplicationJob
  attr_accessor :manifest

  queue_as Hyrax.config.ingest_queue_name

  def perform(manifest)
    # Step 0. Initial preparation
    status.update(manifest: manifest)
    @manifest = manifest

    # Submit jobs for new works to be created
    @manifest['media_ie_pe_ingests'].each do |i|
      if i['parent'].count > 1
        raise "Only one parent should be present for media ingestion, but multiple are present. Parents: #{i['parent']}"
      end

      if !i['imaging_event']&.first.present?
        raise "Imaging event not present for ingest. Ingest: #{i}"
      end

      # Find the BSO associated with media
      ie_row_index = i['imaging_event'].first[0]
      bso = manifest['biological_specimen_ingests'][manifest['rows_to_bso'][ie_row_index]]

      if !bso.present?
        raise "Media ingest requires a biological specimen present. Provided BSO: #{bso}"
      elif !bso['id'].present?
        raise "A supposedly ingested biological specimen does not have ID. Provided BSO: #{bso}"
      end

      i['physical_object_id'] = bso['id']
      i['job'] = BatchSubmission::ConvertedMs1Batch::MediaIePeIngestJob.perform_later(i, @manifest['collection_ids'] || [])

      # Monitor jobs
      sleep(1.minute) until monitor_ingest_jobs

      # Report errors
      status.update(manifest: @manifest)
      if @manifest['media_ie_pe_ingests'].any? { |i| i['job_exception'].present? }
        exceptions = []
        @manifest['media_ie_pe_ingests'].each_with_index do |i, index|
          if i['job_exception'].present?
            exceptions << "Media ingest #{index} failed. Exception: \"#{i['job_exception']}\"."
          end
        end
        raise "One or more media ingests failed. #{exceptions.join('; ')}"
      end

      # Remove jobs from manifest (for further serialization)
      @manifest['media_ie_pe_ingests'].each { |i| i.except!('job') }
      status.update(manifest: @manifest)
    end
  end

  def monitor_ingest_jobs
    jobs_complete = true

    @manifest['media_ie_pe_ingests'].each do |i|
      next unless (job = i['job']).present?

      status = ActiveJob::Status.get(i['job'])
      i['job_status'] = status[:status].to_s
      if status[:status] == :queued || status[:status] == :working
        jobs_complete = false
      elsif status[:status] == :failed
        i['job_exception'] = "Job #{job.class} failed. Exception: #{status[:exception].to_s}"
      elsif status[:status] == :completed
        next          
      else
        i['job_exception'] = "Job #{job.class} produced unexpected status: #{status[:status].to_s}"
      end
    end

    return jobs_complete
  end
end