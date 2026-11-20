require 'rails_helper'

# End-to-end checks of REST API authentication with API keys and OAuth access tokens
# (Morphosource::RestApiBehavior.api_auth). Request specs run the full Warden stack,
# which controller specs do not.
RSpec.describe 'REST API authentication with OAuth access tokens', type: :request do
  let(:user) { FactoryBot.create(:confirmed_user) }
  let(:application) do
    Doorkeeper::Application.create!(name: 'Partner app', redirect_uri: 'https://partner.example.org/callback')
  end

  def bearer_token(scopes:, **attrs)
    token = Doorkeeper::AccessToken.create!(
      { application: application, resource_owner_id: user.id, scopes: scopes, expires_in: 2.hours }.merge(attrs)
    )
    token.plaintext_token
  end

  def json
    JSON.parse(response.body)
  end

  # The user directory is API-key-only (`api_auth :optional, scope: nil`), so OAuth access
  # tokens are refused whatever their scopes.
  describe 'GET /users.json' do
    let(:path) { hyrax.users_path(format: :json) }

    it 'returns 401 without credentials' do
      get path
      expect(response).to have_http_status(:unauthorized)
    end

    it 'accepts an API key' do
      get path, headers: { 'Authorization' => user.token }
      expect(response).to have_http_status(:ok)
    end

    it 'accepts an API key with a Bearer prefix' do
      get path, headers: { 'Authorization' => "Bearer #{user.token}" }
      expect(response).to have_http_status(:ok)
    end

    it 'refuses an OAuth access token holding every API scope' do
      get path, headers: { 'Authorization' => "Bearer #{bearer_token(scopes: 'openid api:read api:download api:reports')}" }
      expect(response).to have_http_status(:forbidden)
      expect(json['error']).to eq('insufficient_scope')
      expect(response.headers['WWW-Authenticate']).to include('does not accept OAuth access tokens')
    end
  end

  # Required endpoints reject requests with no credential.
  describe 'POST /api/download/:id' do
    it 'returns 401 without credentials' do
      post api_media_generate_download_path('000000001')
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns 403 for an OAuth token without api:download' do
      post api_media_generate_download_path('000000001'),
           headers: { 'Authorization' => "Bearer #{bearer_token(scopes: 'openid api:read')}" }
      expect(response).to have_http_status(:forbidden)
      expect(response.headers['WWW-Authenticate']).to include('scope="api:download"')
    end
  end

  describe 'GET /api/media-cart' do
    it 'returns 401 without credentials' do
      get api_media_cart_path
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns the token owner's cart with an OAuth token with api:read" do
      get api_media_cart_path, headers: { 'Authorization' => "Bearer #{bearer_token(scopes: 'openid api:read')}" }
      expect(response).to have_http_status(:ok)
      expect(json.dig('response', 'media_cart')).to eq([])
    end

    it 'returns 403 for an OAuth token without api:read' do
      get api_media_cart_path, headers: { 'Authorization' => "Bearer #{bearer_token(scopes: 'openid api:download')}" }
      expect(response).to have_http_status(:forbidden)
    end
  end

  # The IIIF manifest URL returned by GET /api/media/:id/iiif/manifest accepts the credential
  # directly (api_auth :optional, scope: 'api:read'), without relying on a session cookie.
  describe 'GET /manifests/v3/:access_control_id for private media' do
    let(:media) do
      FactoryBot.create(:media, depositor: user.ms_id).tap do |m|
        m.read_users += [user]
        m.save
      end
    end
    let(:path) { "/manifests/v3/#{media.access_control_id}.json" }

    it 'is not found anonymously' do
      get path
      expect(response).to have_http_status(:not_found)
    end

    it 'returns the manifest with an API key' do
      get path, headers: { 'Authorization' => user.token }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('@context')
    end

    it 'returns the manifest with an OAuth token with api:read' do
      get path, headers: { 'Authorization' => "Bearer #{bearer_token(scopes: 'openid api:read')}" }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('@context')
    end

    it 'returns 403 for an OAuth token without api:read' do
      get path, headers: { 'Authorization' => "Bearer #{bearer_token(scopes: 'openid api:download')}" }
      expect(response).to have_http_status(:forbidden)
    end
  end

  # Media show and search are "enhance" endpoints (api_auth :optional, scope: 'api:read'):
  # a credential reveals private media the user can read.
  context 'private media the user can read' do
    let!(:media) { FactoryBot.create(:private_media_document, read_access_person_ssim: [user.ms_id]) }

    describe 'GET /api/media/:id' do
      let(:path) { api_media_show_path(media.id) }

      it 'is not found anonymously' do
        get path
        expect(response).to have_http_status(:not_found)
      end

      it 'is found with an API key' do
        get path, headers: { 'Authorization' => user.token }
        expect(response).to have_http_status(:ok)
      end

      it 'is found with an OAuth token with api:read' do
        get path, headers: { 'Authorization' => "Bearer #{bearer_token(scopes: 'openid api:read')}" }
        expect(response).to have_http_status(:ok)
      end

      it 'accepts an API key with a Bearer prefix' do
        get path, headers: { 'Authorization' => "Bearer #{user.token}" }
        expect(response).to have_http_status(:ok)
      end

      it 'returns 403 insufficient_scope for an OAuth token without api:read' do
        get path, headers: { 'Authorization' => "Bearer #{bearer_token(scopes: 'openid api:download')}" }
        expect(response).to have_http_status(:forbidden)
        expect(json['error']).to eq('insufficient_scope')
        expect(response.headers['WWW-Authenticate']).to include('error="insufficient_scope"', 'scope="api:read"')
      end

      it 'returns 403 for a login-only token' do
        get path, headers: { 'Authorization' => "Bearer #{bearer_token(scopes: 'openid email profile')}" }
        expect(response).to have_http_status(:forbidden)
      end

      it 'returns 401 invalid_token for an expired token' do
        token = bearer_token(scopes: 'openid api:read', expires_in: 1.hour, created_at: 2.hours.ago)
        get path, headers: { 'Authorization' => "Bearer #{token}" }
        expect(response).to have_http_status(:unauthorized)
        expect(json['error']).to eq('invalid_token')
        expect(response.headers['WWW-Authenticate']).to include('error="invalid_token"')
      end

      it 'returns 401 invalid_token for a revoked token' do
        token = bearer_token(scopes: 'openid api:read')
        Doorkeeper::AccessToken.by_token(token).revoke
        get path, headers: { 'Authorization' => "Bearer #{token}" }
        expect(response).to have_http_status(:unauthorized)
        expect(json['error']).to eq('invalid_token')
      end

      it 'returns 401 invalid_token for an unknown token' do
        get path, headers: { 'Authorization' => "Bearer #{Morphosource::OauthTokenGenerator::PREFIX}unknown" }
        expect(response).to have_http_status(:unauthorized)
        expect(json['error']).to eq('invalid_token')
      end

      it 'does not sign the user in to a session' do
        get path, headers: { 'Authorization' => "Bearer #{bearer_token(scopes: 'openid api:read')}" }
        expect(response).to have_http_status(:ok)

        get path
        expect(response).to have_http_status(:not_found)
      end
    end

    describe 'GET /api/media' do
      def returned_ids
        Array(json.dig('response', 'media')).map { |m| m['id'] }.flatten
      end

      it 'omits the media anonymously' do
        get api_media_search_path
        expect(response).to have_http_status(:ok)
        expect(returned_ids).not_to include(media.id)
      end

      it 'includes the media with an API key' do
        get api_media_search_path, headers: { 'Authorization' => user.token }
        expect(returned_ids).to include(media.id)
      end

      it 'includes the media with an OAuth token with api:read' do
        get api_media_search_path, headers: { 'Authorization' => "Bearer #{bearer_token(scopes: 'openid api:read')}" }
        expect(returned_ids).to include(media.id)
      end
    end
  end
end
