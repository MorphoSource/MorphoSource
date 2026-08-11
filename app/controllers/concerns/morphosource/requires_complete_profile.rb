module Morphosource
  module RequiresCompleteProfile
    extend ActiveSupport::Concern

    private

    # Redirects to the "complete your profile" page if +user+ has no profile_type set.
    # @param user [User]
    # @return [Boolean] true if it redirected (caller should return immediately), false if the profile is already complete
    def redirect_to_complete_profile(user)
      return false if user.profile_type.present?

      raw, hashed = Devise.token_generator.generate(User, :update_profile_token)
      user.update_profile_token = hashed
      user.update_profile_sent_at = Time.now.utc
      user.save
      redirect_to edit_profile_type_path(user, update_profile_token: raw)
      true
    end
  end
end
