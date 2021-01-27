# frozen_string_literal: true

module Morphosource
  class PasswordsController < Devise::PasswordsController

    append_before_action :assert_reset_token_passed, only: [:edit, :ms1_edit]

    def ms1_edit
      self.resource = resource_class.new
      set_minimum_password_length
      resource.reset_password_token = params[:reset_password_token]
    end
  end
end
