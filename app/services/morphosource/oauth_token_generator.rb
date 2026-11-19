# frozen_string_literal: true

module Morphosource
  # Generates Doorkeeper access token values with a fixed prefix (see
  # access_token_generator in config/initializers/doorkeeper.rb).
  #
  # The prefix is how Morphosource::ApiCredential tells an OAuth access token apart from
  # a user API key in the Authorization header. API keys come from has_secure_token
  # (base58, which has no underscore), so they can never start with PREFIX.
  class OauthTokenGenerator
    PREFIX = 'msoat_'

    def self.generate(options = {})
      "#{PREFIX}#{Doorkeeper::OAuth::Helpers::UniqueToken.generate(options)}"
    end
  end
end
