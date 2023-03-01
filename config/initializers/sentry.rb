# This requires an environment variable SENTRY_DSN for token information
Sentry.init do |config|
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  config.environment = ENV['SENTRY_ENV'] || Rails.env

  # sample one-third of errors
  config.sample_rate = 0.333

  # disable transaction sampling
  config.traces_sample_rate = 0.0
end