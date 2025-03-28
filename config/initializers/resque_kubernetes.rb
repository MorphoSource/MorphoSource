Resque::Kubernetes.configuration do |config|
  config.enabled     = Rails.env.production?
  # only ever run one job at a time
  config.max_workers = 1
end