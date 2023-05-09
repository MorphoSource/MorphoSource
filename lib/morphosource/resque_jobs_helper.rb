module Morphosource
  module ResqueJobsHelper

    def active_jobs(job_class)
      (queued_resque_jobs + working_resque_jobs).select { |j| j["job_class"] == job_class }
    end

    def queued_resque_jobs
      @queued_resque_jobs ||= begin
        Resque.data_store.queue_names
          .map { |n| Resque.data_store.everything_in_queue(n) }
          .flatten
          .map { |j| Resque.decode(j)["args"][0] || {} }  
      end
    end

    def failed_resque_jobs
      @failed_resque_jobs ||= begin
        Resque::Failure.all(0, 999999)
          .map { |j| (j["payload"]["args"][0] || {}).merge(
            "exception" => j["exception"], 
            "error" => j["error"], 
            "failed_at" => j["failed_at"]
          )}  
      end
    end

    def working_resque_jobs
      @working_resque_jobs ||= begin
        Resque.workers
          .map { |w| w.job }
          .select { |j| j.present? }
          .map { |j| (j["payload"]["args"][0] || {}).merge(
            "run_at" => j["run_at"] 
          )}
      end
    end

	end
end