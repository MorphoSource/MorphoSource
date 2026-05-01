# frozen_string_literal: true

return unless Hyrax.config.enable_identity_provider?

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
  default_scopes  :openid
  optional_scopes :email, :profile, :admin

  # Security settings
  grant_flows %w[authorization_code]
  use_refresh_token

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
