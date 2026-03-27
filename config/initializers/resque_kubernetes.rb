Resque::Kubernetes.configuration do |config|
  config.enabled              = Rails.env.production?
  # only ever run one job at a time
  config.max_workers          = ENV.fetch('RESQUE_K8S_MAX_WORKERS', '1').to_i
  # always query K8S at namespace level and not at cluster level
  config.namespace_scope_only = true
end