class MassIngest::ConvertedMs1Batch::TaxonomySubcontrolJob < ApplicationJob
  attr_accessor :manifest

  queue_as Hyrax.config.ingest_queue_name

  def perform(manifest)
    # Step 0. Initial preparation
    status.update(manifest: manifest)
    progress.total = 4
    @manifest = manifest
    
    raise "Totally arbitrary error, nyan"
  end

  def monitor_status(job)
    status = ActiveJob::Status.get(job)
    if status[:status] == :failed
      raise "Job #{job['args'][0]['job_class']} failed. Exception: #{job[:exception]}"
    elsif status[:status] == :queued || status[:status] == :working
      return false
    elsif status[:status] == :completed
      new_manifest = status[:manifest]
      if new_manifest.present? && new_manifest.is_a?(Hash)
        status.update(manifest: new_manifest)
        @manifest = new_manifest
        return true
      else
        raise "Job #{job['args'][0]['job_class']} returned a malformed manifest with value #{new_manifest}"
      end
    else
      raise "Job #{job['args'][0]['job_class']} produced unexpected status: #{job[:status]}"
    end
  end
end