class MassIngest::ConvertedMs1Batch::MassIngestControlJob < ApplicationJob
  attr_accessor :manifest

  queue_as Hyrax.config.ingest_queue_name

  def perform(manifest)
    begin
      # Step 0. Initial preparation
      status.update(manifest: manifest)
      progress.total = 4
      @manifest = manifest
      
      sub_jobs.each do |job_class|
        job = job_class.send :perform_later, @manifest
        sleep(1.minute) until monitor_status(job)
        progress.increment
      end
    ensure
      status.update(manifest: @manifest)
    end
  end

  def sub_jobs
    [
      MassIngest::ConvertedMs1Batch::TaxonomySubcontrolJob
    ]
  end

  def monitor_status(job)
    status = ActiveJob::Status.get(job)
    if status[:status] == :failed
      raise "Job #{job.class} failed. Exception: #{status[:exception]}"
    elsif status[:status] == :queued || status[:status] == :working
      return false
    elsif status[:status] == :completed
      new_manifest = status[:manifest]
      if new_manifest.present? && new_manifest.is_a?(Hash)
        status.update(manifest: new_manifest)
        @manifest = new_manifest
        return true
      else
        raise "Job #{job.class} returned a malformed manifest with value #{new_manifest}"
      end
    else
      raise "Job #{job.class} produced unexpected status: #{job[:status]}"
    end
  end

  # if ingest fails, need to delete mid-stream works
  def delete_garbage_works
    status.update(work_deletion: :working)

    related_ids = []
    @manifest[:media_ie_pe_ingests].each do |i|
      i[:children].each do |k, combined_pe_media|
        related_ids.concat delete_work_if_needed(combined_pe_media[:media])
        related_ids.concat delete_work_if_needed(combined_pe_media[:pe])
      end

      i[:parent].each do |k, combined_pe_media|
        related_ids.concat delete_work_if_needed(combined_pe_media[:media])
        related_ids.concat delete_work_if_needed(combined_pe_media[:pe])
      end

      related_ids.concat delete_work_if_needed(i[:imaging_event].values.first)
    end

    @manifest[:biological_specimen_ingests].each do |i|
      related_ids.concat delete_work_if_needed(i)
    end

    @manifest[:taxonomy_ingests].each do |i|
      related_ids.concat delete_work_if_needed(i)
    end

    final_related_ids = related_ids
      .uniq
      .select { |id| ActiveFedora::Base.find(id) if ActiveFedora::Base.exists?(id) }
      .compact
    UpdateRelatedWorksIndexJob.perform_later(final_related_ids)

    status.update(work_deletion: :completed)
  end

  def delete_work_if_needed(ingest)
    related_work_ids = []

    if i[:job].present? && i[:job_status] == :completed && i[:id].present? && ActiveFedora::Base.exists?(i[:id])
      work = ActiveFedora::Base.find(i[:id])
      case work.class
      when ImagingEvent
        related_work_ids.concat(work.objects) if work.objects.present?
      when ProcessingEvent
        related_work_ids << work.imaging_event if work.imaging_event.present?
      when Media
        related_work_ids << work.processing_event if work.processing_event.present?
      end
      work.destroy
    end

    return related_work_ids
  end
end