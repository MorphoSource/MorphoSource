require 'digest'

class SessionsController < Devise::SessionsController
  prepend_before_action :require_no_authentication, only: [:edit_profile_type]
  before_action :check_profile_type, only: :create

  def check_profile_type
    self.resource = warden.authenticate!(auth_options)
    unless resource.profile_type.present? 
      if params[:user][:profile_type].present?
        # save profile type info and continue
        user = User.find(resource.id)
        permitted_attributes = params.require(:user).permit(
          "profile_type",
          "academic_institution_or_school",
          "department",
          "academic_field",
          "academic_subfield",
          "mentor_or_advisor",
          "instructor",
          "affiliation",
          demographics: [] 
        )
        user.update(permitted_attributes)
      else
        session[:user_email] = resource.email
        session[:user_password] = params[:user][:password]
        sign_out(resource)
        redirect_to edit_profile_type_path
      end
    end
  end
  
  def edit_profile_type
    @user_email = session[:user_email]
    @user_password = session[:user_password]
    session.delete(:user_email)
    session.delete(:user_password)
    self.resource = resource_class.new(sign_in_params)
    clean_up_passwords(resource)
    yield resource if block_given?
    respond_with(resource, serialize_options(resource))
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
