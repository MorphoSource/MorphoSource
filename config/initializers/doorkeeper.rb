# frozen_string_literal: true

# Always configure Doorkeeper so its ORM hooks (registered by doorkeeper-openid_connect
# at gem load time) don't raise MissingConfiguration during app initialization.
# Whether the OAuth/OIDC endpoints are actually exposed is controlled by
# Hyrax.config.enable_identity_provider? in config/routes.rb.
Doorkeeper.configure do
  orm :active_record

  # This block determines whether the resource owner is authenticated or not.
  resource_owner_authenticator do
    current_user || begin
      store_location_for(:user, request.fullpath)
      authenticate_user!
    end
  end

  # Restrict access to the Doorkeeper admin panel to MorphoSource admins
  admin_authenticator do
    current_user&.admin? || head(:not_found)
  end

  # Force SSL in production for security
  force_ssl_in_redirect_uri Rails.env.production?

  # Define scopes. 'openid' is required for OIDC.
  # 'admin' allows third-party apps to request admin status checks.
  #
  # 'api:*' scopes let an application call the MorphoSource REST API on the user's
  # behalf by sending its access token in the Authorization header. A token can only
  # reach endpoints that declare one of its scopes (see Morphosource::RestApiBehavior.api_auth),
  # and never more than the user could do with their own API key.
  #   api:read     - search and view records, including private records the user can access
  #   api:download - generate download links and download media
  #   api:reports  - collection exports and download/request reports (collection managers)
  #
  # These scopes cover only the endpoints in the public API docs (https://www.morphosource.org/api/docs).
  # Other API-key endpoints, such as fund code charges and the user directory, are API-key-only.
  default_scopes  :openid
  optional_scopes :email, :profile, :admin, :'api:read', :'api:download', :'api:reports'

  # Reject authorization requests for scopes not listed above. Per-application limits
  # are set in each application's "Scopes" field in the admin UI; leave it blank and
  # the application may request any configured scope.
  enforce_configured_scopes

  # Security settings
  grant_flows %w[authorization_code]
  use_refresh_token

  # Store SHA-256 digests of access and refresh tokens rather than plaintext. The :plain
  # fallback lets tokens issued before this setting keep working; Doorkeeper upgrades
  # them to hashed values the first time they are looked up.
  hash_token_secrets fallback: :plain

  # Access tokens carry a recognizable prefix so they can be told apart from user API
  # keys in logs and support requests, and so secret scanners can detect leaked tokens.
  access_token_generator '::Morphosource::OauthTokenGenerator'

  # Explicit, short-lived authorization codes (default is 10 minutes).
  authorization_code_expires_in 5.minutes

  # Access tokens valid for 2 hours; refresh tokens do not expire by default.
  access_token_expires_in 2.hours

  # Skip the consent screen for first-party applications marked as such in the admin UI.
  skip_authorization do |_resource_owner, client|
    client.application.skip_authorization?
  end

  # Use PKCE for increased security (required for public clients / OIDC)
  allow_blank_redirect_uri false
  force_pkce
end
