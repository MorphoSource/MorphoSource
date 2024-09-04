# This requires an environment variable SENTRY_DSN for token information
Sentry.init do |config|
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # disable server logs
  config.logger = Logger.new(nil)

  config.environment = ENV['SENTRY_ENV'] || Rails.env

  # sample all errors (previously sample one-third of errors)
  config.sample_rate = 1.0

  # disable transaction sampling
  config.traces_sample_rate = 0.0

  exceptions_do_not_send = [I18n::InvalidLocale]
  config.before_send = lambda do |event, hint|
    # skip certain exceptions
    # note: hint[:exception] would be a String if you use async callback
    if exceptions_do_not_send.include?(hint[:exception])
      nil
    else
      event
    end
  end
end