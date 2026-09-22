# frozen_string_literal: true

module Morphosource
  class PasswordsController < Devise::PasswordsController
    include Morphosource::RequiresCompleteProfile

    append_before_action :assert_reset_token_passed, only: [:edit, :ms1_edit]

    def update
      super do |resource|
        if resource.errors.empty? && resource.profile_type.blank?
          # Sign in now since edit_profile_type's authorize_resource needs a current_user.
          sign_in(resource_name, resource)
          redirect_to_complete_profile(resource) and return
        end
      end
    end

    def ms1_edit
      self.resource = resource_class.new
      set_minimum_password_length
      resource.reset_password_token = params[:reset_password_token]
    end
  end
end
