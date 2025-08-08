Resque::Kubernetes.configuration do |config|
  config.enabled              = Rails.env.production?
  # only ever run one job at a time
  config.max_workers          = 1
  # always query K8S at namespace level and not at cluster level
  config.namespace_scope_only = true
end