# Authenticates REST API requests that send an OAuth access token issued by the
# MorphoSource identity provider ("Authorization: Bearer msoat_...").
#
# This strategy only establishes who the user is. Scope checks happen in
# Morphosource::RestApiBehavior#authenticate_api, which every API endpoint runs.
class OauthTokenStrategy < Warden::Strategies::Base
  def valid?
    credential.oauth?
  end

  # Never put the user in the session. A session cookie would let later requests from
  # the client skip the token's expiry, revocation and scope checks.
  def store?
    false
  end

  def authenticate!
    if credential.valid_oauth_token?
      success!(credential.user)
    else
      fail!('Invalid, expired or revoked OAuth access token')
    end
  end

  private

    def credential
      Morphosource::ApiCredential.from_env(env)
    end
end
