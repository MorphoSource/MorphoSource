# frozen_string_literal: true

module Morphosource
  # The credential a REST API client sent in the Authorization header.
  #
  # The header may hold either a user's API key or an OAuth access token issued by the
  # MorphoSource identity provider, with or without a "Bearer " prefix:
  #
  #   Authorization: <api key>
  #   Authorization: Bearer <api key>
  #   Authorization: Bearer msoat_<oauth access token>
  #
  # A value starting with OauthTokenGenerator::PREFIX is treated as an OAuth access token
  # and is never looked up as an API key; any other value is treated as an API key.
  #
  # One instance is memoized per request so the Warden strategies and controllers share
  # the same lookups.
  class ApiCredential
    ENV_KEY = 'morphosource.api_credential'
    BEARER_PREFIX = /\ABearer\s+/i

    def self.from_env(env)
      header = env['HTTP_AUTHORIZATION']
      cached = env[ENV_KEY]
      return cached if cached && cached.header == header

      env[ENV_KEY] = new(header)
    end

    attr_reader :header, :value

    def initialize(header)
      @header = header
      @value = header.to_s.strip.sub(BEARER_PREFIX, '')
    end

    def present?
      value.present?
    end

    def oauth?
      present? && value.start_with?(OauthTokenGenerator::PREFIX)
    end

    def api_key?
      present? && !oauth?
    end

    # The Doorkeeper access token, whether or not it is still valid. Nil for API keys.
    def oauth_token
      return @oauth_token if defined?(@oauth_token)

      @oauth_token = oauth? ? Doorkeeper::AccessToken.by_token(value) : nil
    end

    # True for an OAuth access token that exists, is not expired or revoked, and
    # belongs to an existing user.
    def valid_oauth_token?
      oauth_token.present? && oauth_token.accessible? && user.present?
    end

    def includes_scope?(scope)
      scope.present? && valid_oauth_token? && oauth_token.includes_scope?(scope.to_s)
    end

    # The user the credential authenticates, or nil if it is missing or invalid.
    def user
      return @user if defined?(@user)

      @user =
        if oauth?
          oauth_token&.accessible? ? User.find_by(id: oauth_token.resource_owner_id) : nil
        elsif present?
          User.find_by(token: value)
        end
    end
  end
end
