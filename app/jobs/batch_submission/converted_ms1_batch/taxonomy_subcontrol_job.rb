class BatchSubmission::ConvertedMs1Batch::TaxonomySubcontrolJob < ApplicationJob
  attr_accessor :manifest

  queue_as Hyrax.config.ingest_queue_name

  def perform(manifest)
    # Step 0. Initial preparation
    status.update(manifest: manifest)
    @manifest = manifest
    
    # Submit jobs for new works to be created
    @manifest['taxonomy_ingests'].each do |t|
      t['job'] = ::BatchObjectImportJob.perform_later('Taxonomy', t['attrs'].symbolize_keys, nil, false) if !t['id'].present? # new work to be created
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
      next unless (job = t['job']).present?

      status = ActiveJob::Status.get(t['job'])
      t['job_status'] = status[:status].to_s
      if status[:status] == :queued || status[:status] == :working
        jobs_complete = false
      elsif status[:status] == :failed
        t['job_exception'] = "Job #{job.class} failed. Exception: #{status[:exception].to_s}"
      elsif status[:status] == :completed
        if status[:id].present?
          t['id'] = status[:id]
        else
          t['job_exception'] = "Job #{job.class} completed successfully, but produced no work ID."
        end
      else
        t['job_exception'] = "Job #{job.class} produced unexpected status: #{status[:status].to_s}"
      end
    end

    return jobs_complete
  end
end