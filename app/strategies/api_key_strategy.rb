# Authenticates REST API requests that send a user's API key in the Authorization
# header, with or without a "Bearer " prefix. OAuth access tokens are handled by
# OauthTokenStrategy; see Morphosource::ApiCredential for how the two are told apart.
class ApiKeyStrategy < Warden::Strategies::Base
  def valid?
    credential.api_key?
  end

  def authenticate!
    user = credential.user

    if user
      success!(user)
    else
      fail!('Invalid email or password')
    end
  end

  private

    def credential
      Morphosource::ApiCredential.from_env(env)
    end
end
