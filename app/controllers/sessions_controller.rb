require 'digest'

class SessionsController < Devise::SessionsController

  def create
    unless current_user.profile_type.present?
      super do |resource|
        if resource.persisted?
          redirect_to edit_profile_type_path(resource) and return
        end
      end
    end
    super
  end

  def new
    if sign_in_params[:email] and sign_in_params[:password]
      u = User.find_by email: sign_in_params[:email]
      if u.present? and u.ms1_user and Digest::MD5.hexdigest(sign_in_params[:password]) == u.ms1_password_hash
        flash[:alert] = t("devise.passwords.edit.ms1_user_flash")
        raw, hashed = Devise.token_generator.generate(User, :reset_password_token)
        u.reset_password_token = hashed
        u.reset_password_sent_at = Time.now.utc
        u.save
        redirect_to Rails.application.routes.url_helpers.ms1_edit_user_password_path(reset_password_token: raw)
        return
      end
    end
    super
  end
end
