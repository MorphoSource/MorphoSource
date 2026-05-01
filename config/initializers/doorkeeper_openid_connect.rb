# frozen_string_literal: true

return unless Hyrax.config.enable_identity_provider?

Doorkeeper::OpenidConnect.configure do
  # OIDC spec requires a full HTTPS URL as the issuer, not just a hostname.
  issuer "https://#{Hyrax.config.host_name}"

  # The signing key for the JWT tokens.
  # In production, set OIDC_PRIVATE_KEY to a PEM-formatted RSA private key.
  # ENV vars often store newlines as literal \n — gsub converts them back.
  signing_key ENV.fetch('OIDC_PRIVATE_KEY', nil)&.gsub('\\n', "\n")

  subject_types_supported [:public]

  resource_owner_from_access_token do |access_token|
    User.find(access_token.resource_owner_id)
  end

  auth_time_from_resource_owner do |resource_owner|
    resource_owner.current_sign_in_at
  end

  subject do |resource_owner, _application|
    resource_owner.ms_id
  end

  claims do
    claim :email, scope: :email do |resource_owner|
      resource_owner.email
    end

    claim :profile, scope: :profile do |resource_owner|
      { name: resource_owner.name }
    end

    claim :admin, scope: :admin do |resource_owner|
      resource_owner.admin?
    end
  end
end
