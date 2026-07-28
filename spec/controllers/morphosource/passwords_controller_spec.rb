require 'rails_helper'

RSpec.describe Morphosource::PasswordsController, type: :controller do
  let(:user)  { User.create(email: "example@email.com", password: "password", profile_type: "test") }
  let(:user2) { User.create(email: "user2@email.com", password: "password2", profile_type: nil) }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  def reset_token_for(u)
    raw, hashed = Devise.token_generator.generate(User, :reset_password_token)
    u.update(reset_password_token: hashed, reset_password_sent_at: Time.now.utc)
    raw
  end

  describe 'PATCH #update' do
    context 'when profile_type is present' do
      it 'does not redirect to edit_profile_type_path' do
        raw = reset_token_for(user)
        patch :update, params: { user: { reset_password_token: raw, password: 'newpassword1', password_confirmation: 'newpassword1' } }
        expect(response).not_to redirect_to(edit_profile_type_path(user.id))
      end
    end

    context 'when profile_type is not present' do
      it 'redirects to edit_profile_type_path with a valid update_profile_token' do
        raw = reset_token_for(user2)
        patch :update, params: { user: { reset_password_token: raw, password: 'newpassword2', password_confirmation: 'newpassword2' } }
        expect(response.redirect_url).to include(edit_profile_type_path(user2.ms_id))
        user2.reload
        expect(user2.update_profile_token).to be_present
      end
    end

    context 'with an invalid reset token' do
      it 'does not redirect to edit_profile_type_path' do
        patch :update, params: { user: { reset_password_token: 'bogus', password: 'newpassword3', password_confirmation: 'newpassword3' } }
        expect(response).not_to redirect_to(edit_profile_type_path(user2.ms_id))
      end
    end
  end
end
