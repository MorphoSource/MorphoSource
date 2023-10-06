class RegistrationsController < Devise::RegistrationsController
  include Morphosource::UserProfile::ProfilesBehavior

  before_action :strip_empty_values, :check_profile_type, only: [:create]

  def new 
    @all_metadata_fields = all_metadata_fields_hash
    @required_metadata_fields = required_metadata_fields_hash
    super
  end

  protected

  def sign_up_params
    params.require(:user).permit(:address, :affiliation, :sftp_share, :avatar, :country, :department, :display_name, :email, :facebook_handle, :linkedin_handle, :orcid, :password, :password_confirmation, :postal_code, :remove_avatar, :state, :telephone, :terms_read, :twitter_handle, :website, demographics: [], software: [], intent: [], mesh_file_type: [], volume_file_type: [], printer_file: [], printer_model: [] )
  end

  # Don't retain empty strings from 'other' fields.
  def strip_empty_values
    User::MULTI_VALUE_FIELDS.keys.each do |field|
      params[:user][field].delete_if(&:empty?)
    end
  end

  def redirect_with_error(messages)
    flash[:error] = messages
    redirect_to main_app.new_user_registration_path 
  end

end
