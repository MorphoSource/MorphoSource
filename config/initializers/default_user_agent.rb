# frozen_string_literal: true

# Apply a default User-Agent to outbound HTTP requests when one isn't provided.
Rails.application.config.after_initialize do
  ua = Hyrax.config.remote_request_headers&.[]("User-Agent")
  next unless ua.present?

  Net::HTTP.prepend(Module.new do
    define_method(:request) do |req, body = nil, &block|
      req["User-Agent"] ||= ua
      super(req, body, &block)
    end
  end)

  # HTTP.rb (used in some code paths) supports default headers.
  if defined?(HTTP)
    HTTP.default_options = HTTP.default_options.merge(headers: {"User-Agent" => ua})
  end
end
