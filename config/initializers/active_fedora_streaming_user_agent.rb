# frozen_string_literal: true

# Ensure ActiveFedora streaming requests include the MorphoSource User-Agent.
Rails.application.config.after_initialize do
  next unless Hyrax.config.remote_request_headers&.[]("User-Agent").present?

  ActiveFedora::File::Streaming.prepend(Module.new do
    def each(&block)
      ua = Hyrax.config.remote_request_headers&.[]("User-Agent")
      return super(&block) unless ua.present?
      return super(&block) unless respond_to?(:uri) && uri&.host
      return super(&block) unless respond_to?(:open)

      open(uri, headers: { "User-Agent" => ua }, &block)
    end
  end)
end
