require 'rails_helper'

# Users can see and revoke the OAuth applications they have authorized, linked from the
# "Advanced User Functions" section of their profile dashboard.
RSpec.describe 'Authorized applications', type: :request do
  let(:user) { FactoryBot.create(:confirmed_user) }
  let(:application) do
    Doorkeeper::Application.create!(name: 'Partner app', redirect_uri: 'https://partner.example.org/callback')
  end
  let!(:token) do
    Doorkeeper::AccessToken.create!(application: application, resource_owner_id: user.id,
                                    scopes: 'openid api:read', expires_in: 2.hours, use_refresh_token: true)
  end

  # The /oauth routes are drawn at boot only when the identity provider is enabled.
  def skip_unless_identity_provider_routes
    skip 'identity provider routes are not mounted' unless
      Rails.application.routes.named_routes.key?(:oauth_authorized_applications)
  end

  before { sign_in user }

  describe 'profile dashboard link' do
    it 'links to authorized applications when the identity provider is enabled' do
      skip_unless_identity_provider_routes
      get profile_show_path(user)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Authorized Applications', oauth_authorized_applications_path)
    end

    it 'hides the link when the identity provider is disabled' do
      allow(Hyrax.config).to receive(:enable_identity_provider?).and_return(false)
      get profile_show_path(user)
      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include('Authorized Applications')
    end
  end

  describe 'authorized applications page' do
    before { skip_unless_identity_provider_routes }

    it 'lists applications the user has authorized' do
      get oauth_authorized_applications_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Partner app')
    end

    it "revoking an application revokes the user's tokens for it" do
      delete oauth_authorized_application_path(application)
      expect(token.reload).to be_revoked
    end
  end
end
