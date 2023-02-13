# This requires an environment variable SENTRY_DSN for token information
Sentry.init do |config|
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Limit Sentry to development for now
  config.enabled_environments = %w[development]

  # Set traces_sample_rate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production.
  config.traces_sample_rate = 1.0
end