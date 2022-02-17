class BatchSubmissionJobs::Ms2Batch::TaxonomySubcontrolJob < Morphosource::ApplicationJobWithStatus
  attr_accessor :manifest

  queue_as Hyrax.config.ingest_queue_name

  def perform(manifest)
    # Step 0. Initial preparation
    status.update(manifest: manifest)
    @manifest = manifest    
#byebug

    # Submit jobs for new works to be created
    @manifest['taxonomy_ingests'].each do |t|
#byebug
      t['job'] = ::BatchObjectImportJob.perform_later('Taxonomy', t['attrs'].symbolize_keys, nil, false) if !t['id'].present? 
      #t['job'] = ::BatchObjectImportJob.perform_now('Taxonomy', t['attrs'].symbolize_keys, nil, false) if !t['id'].present? 
    end

    # Monitor jobs
    sleep(1.minute) until monitor_works_to_be_created

    # Report errors
    status.update(manifest: @manifest)
    if @manifest['taxonomy_ingests'].any? { |t| t['job_exception'].present? }
      exceptions = []
      @manifest['taxonomy_ingests'].each_with_index do |t, index|
        if t['job_exception'].present?
          exceptions << "Taxonomy ingest #{index} failed. Exception: \"#{t['job_exception']}\". Supplied attributes were: \"#{t['attrs']}\""
        end
      end
      raise "One or more taxonomy ingests failed. #{exceptions.join('; ')}"
    end

    # Remove BatchObjectImportJobs from manifest
    @manifest['taxonomy_ingests'].each { |t| t.except!('job') }
    status.update(manifest: @manifest)
  end

  def monitor_works_to_be_created
    jobs_complete = true

    @manifest['taxonomy_ingests'].each do |t|
      if t['job'] == true # it returns true if perform_now has been called (can be removed later if perform_later is called)
#byebug
# get or set id here ?

        # update manifest
        status.update(manifest: @manifest)

        next
      end

      next unless (job = t['job']).present?
      # check job status
      job_status = ActiveJob::Status.get(t['job'])
#byebug
      t['job_status'] = job_status[:status].to_s
      if job_status[:status] == :queued || job_status[:status] == :working
        jobs_complete = false
      elsif job_status[:status] == :failed
        t['job_exception'] = "Job #{job.class} failed. Exception: #{job_status[:exception].to_s}"
      elsif job_status[:status] == :completed
        if job_status[:id].present?
          t['id'] = job_status[:id]
        else
          t['job_exception'] = "Job #{job.class} completed successfully, but produced no work ID."
        end
      else
        t['job_exception'] = "Job #{job.class} produced unexpected status: #{job_status[:status].to_s}"
      end

      # update manifest
      status.update(manifest: @manifest)
    end

    return jobs_complete
  end
end