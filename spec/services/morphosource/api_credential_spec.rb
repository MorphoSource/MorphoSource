require 'rails_helper'

RSpec.describe Morphosource::ApiCredential do
  let(:user) { FactoryBot.create(:confirmed_user) }
  let(:application) do
    Doorkeeper::Application.create!(name: 'Partner app', redirect_uri: 'https://partner.example.org/callback')
  end

  def access_token(scopes: 'openid api:read', **attrs)
    Doorkeeper::AccessToken.create!(
      { application: application, resource_owner_id: user.id, scopes: scopes, expires_in: 2.hours }.merge(attrs)
    )
  end

  describe 'parsing the header' do
    it 'is blank without a header' do
      credential = described_class.new(nil)
      expect(credential).not_to be_present
      expect(credential).not_to be_oauth
      expect(credential).not_to be_api_key
      expect(credential.user).to be_nil
    end

    it 'treats a bare value as an API key' do
      credential = described_class.new(user.token)
      expect(credential).to be_api_key
      expect(credential.user).to eq(user)
    end

    it 'accepts an API key with a Bearer prefix' do
      credential = described_class.new("Bearer #{user.token}")
      expect(credential).to be_api_key
      expect(credential.user).to eq(user)
    end

    it 'matches the Bearer prefix case-insensitively' do
      expect(described_class.new("bearer #{user.token}").user).to eq(user)
    end

    it 'returns no user for an unknown API key' do
      expect(described_class.new('nonsense').user).to be_nil
    end
  end

  describe 'OAuth access tokens' do
    it 'issues access tokens with the OAuth prefix' do
      expect(access_token.plaintext_token).to start_with(Morphosource::OauthTokenGenerator::PREFIX)
    end

    it 'stores tokens hashed rather than in plaintext' do
      token = access_token
      expect(token.reload.token).not_to eq(token.plaintext_token)
    end

    it 'authenticates a valid token sent with Bearer' do
      credential = described_class.new("Bearer #{access_token.plaintext_token}")
      expect(credential).to be_oauth
      expect(credential).to be_valid_oauth_token
      expect(credential.user).to eq(user)
    end

    it 'never looks a prefixed value up as an API key' do
      user.update_column(:token, "#{Morphosource::OauthTokenGenerator::PREFIX}lookalike")
      credential = described_class.new(user.token)
      expect(credential).to be_oauth
      expect(credential.user).to be_nil
    end

    it 'checks scopes' do
      credential = described_class.new("Bearer #{access_token(scopes: 'openid api:read').plaintext_token}")
      expect(credential.includes_scope?('api:read')).to be true
      expect(credential.includes_scope?('api:download')).to be false
      expect(credential.includes_scope?(nil)).to be false
    end

    it 'rejects an expired token' do
      token = access_token(expires_in: 1.hour, created_at: 2.hours.ago)
      credential = described_class.new("Bearer #{token.plaintext_token}")
      expect(credential).not_to be_valid_oauth_token
      expect(credential.user).to be_nil
      expect(credential.includes_scope?('api:read')).to be false
    end

    it 'rejects a revoked token' do
      token = access_token
      raw = token.plaintext_token
      token.revoke
      credential = described_class.new("Bearer #{raw}")
      expect(credential).not_to be_valid_oauth_token
      expect(credential.user).to be_nil
    end

    it 'rejects an unknown prefixed token' do
      credential = described_class.new("Bearer #{Morphosource::OauthTokenGenerator::PREFIX}unknown")
      expect(credential).to be_oauth
      expect(credential).not_to be_valid_oauth_token
    end
  end

  describe '.from_env' do
    it 'memoizes per header value' do
      env = { 'HTTP_AUTHORIZATION' => user.token }
      first = described_class.from_env(env)
      expect(described_class.from_env(env)).to be(first)

      env['HTTP_AUTHORIZATION'] = 'something else'
      expect(described_class.from_env(env)).not_to be(first)
    end
  end
end
