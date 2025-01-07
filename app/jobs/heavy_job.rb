# Heavy queue jobs potentially run on dedicated highmem k8s pod
class HeavyJob < Hyrax::ApplicationJob
  include Resque::Kubernetes::Job
  queue_as Hyrax.config.heavy_queue_name

  # If resque-kubernetes is enabled, this manifest is used to spawn k8s job
  # Manifest yaml file is created by Helm chart
  def job_manifest
    YAML.load_file Rails.root.join("vendor", "k8s", "worker_heavy_job_manifest.yaml")
  end

  # If resque-kubernetes is enabled, max number of parallel k8s jobs spawned
  def max_workers
    # Simply return an integer value, or do something more complicated if needed.
    1
  end
end