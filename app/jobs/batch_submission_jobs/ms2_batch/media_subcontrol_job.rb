class BatchSubmissionJobs::Ms2Batch::MediaSubcontrolJob < Morphosource::ApplicationJobWithStatus
  attr_accessor :manifest, :created_media

  queue_as Hyrax.config.ingest_queue_name

  def perform(manifest)
    # Step 0. Initial preparation
    status.update(manifest: manifest)
    @manifest = manifest
    @created_media = {}

    # Submit jobs for new works to be created
    @manifest['media_ie_pe_ingests'].each_with_index do |i, ingest_index|
      if i['parent'].present?
        if i['parent'].count > 1
          raise "Only one parent should be present for media ingestion, but multiple are present. Parents: #{i['parent']}"
        end
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

      # check if the ingest depends on a derived parent
      derived_parent_file = ""
      i['children'].each do |idx, child|
        if child['media'].present?
          derived_parent_file = child['media']['derived_parent_file']
          break if derived_parent_file.present?
        end
      end            

      if derived_parent_file.present?
        Rails.logger.debug "In MediaSubcontrolJob: waiting for parent media creation: #{derived_parent_file}"        
        sleep(1.minute) until (target_parent_id = created_parent_id(derived_parent_file)).present?
        Rails.logger.debug "In MediaSubcontrolJob: parent media created: #{derived_parent_file}"
        # save created_media before removing it from job status
        @created_media[derived_parent_file] = target_parent_id
      end

      # Remove jobs from manifest (for further serialization, preventing ActiveJob::SerializationError)
      @manifest['media_ie_pe_ingests'].each { |i| i.except!('job') }
      status.update(manifest: @manifest)

      i['job'] = BatchSubmissionJobs::Ms2Batch::MediaIePeIngestJob.perform_later(
        @manifest,
        i, 
        ingest_index,
        @manifest['collection_ids'] || [],
        @manifest['fund_code_id'] || nil,
        target_parent_id
      )
    end

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

  def created_parent_id(parent_file)
    id = nil
    if @created_media[parent_file].present?
      return @created_media[parent_file]
    end

    @manifest['media_ie_pe_ingests'].each do |i|
      next unless (job = i['job']).present?
      job_status = ActiveJob::Status.get(i['job'])
      i['job_status'] = job_status[:status].to_s
      if (job_status[:status] == :completed)
        # get parent id 
        id = job_status[:created_media][parent_file]
      end
      break if id.present?
    end
    return id    
  end

  def monitor_ingest_jobs
    jobs_complete = true

    @manifest['media_ie_pe_ingests'].each do |i|
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
        next          
      else
        i['job_exception'] = "Job #{job.class} produced unexpected status: #{job_status[:status].to_s}"
      end
      # update manifest
      status.update(manifest: @manifest)
    end

    return jobs_complete
  end
end
