require 'rails_helper'

RSpec.describe 'Password reset', type: :request do
  def reset_token_for(u)
    raw, hashed = Devise.token_generator.generate(User, :reset_password_token)
    u.update(reset_password_token: hashed, reset_password_sent_at: Time.now.utc)
    raw
  end

  def submit_new_password(raw)
    patch '/users/password', params: {
      user: {
        reset_password_token: raw,
        password: 'NewPassw0rd123!',
        password_confirmation: 'NewPassw0rd123!'
      }
    }
  end

  context 'when profile_type is blank' do
    let(:user) { User.create(email: 'incomplete@email.com', password: 'password', profile_type: nil) }

    it 'follows through to a working edit_profile_type page instead of erroring' do
      submit_new_password(reset_token_for(user))
      expect(response.redirect_url).to include(edit_profile_type_path(user.ms_id))

      follow_redirect!
      expect(response).to have_http_status(:success)
    end
  end

  context 'when profile_type is present' do
    let(:user) { User.create(email: 'complete@email.com', password: 'password', profile_type: 'Artist') }

    it 'redirects to the normal signed-in root page' do
      submit_new_password(reset_token_for(user))
      expect(response).to redirect_to(root_path)
    end
  end
end
