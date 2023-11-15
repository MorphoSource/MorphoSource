class RegistrationsController < Devise::RegistrationsController
  include Morphosource::Users::ProfileHelper

  with_themed_layout 'morphosource_1_column'
  before_action :strip_empty_values, :check_profile_type, only: [:create]

  def new
    @presenter = Morphosource::UserProfilePresenter.new(@user, current_ability)
    super
  end

  def create
    @presenter = Morphosource::UserProfilePresenter.new(@user, current_ability)
    super
  end


  protected

  def sign_up_params
    # todo: remove the following fields, and clean up later
    # Postal Code
    # Telephone
    # Software to view 3D
    # File Type for 3D Mesh
    # File Type for 3D Volume
    # 3D Printer Machine Type
    # 3D Printer File Type
    existing_permit_list = [
      :address,
      :affiliation,
      :sftp_share,
      :avatar,
      :country,
      :department,
      :display_name,
      :email,
      :facebook_handle,
      :linkedin_handle,
      :orcid,
      :password,
      :password_confirmation,
      :postal_code,
      :remove_avatar,
      :state,
      :telephone,
      :terms_read,
      :twitter_handle,
      :website,
      demographics: [],
      software: [],
      intent: [],
      mesh_file_type: [],
      volume_file_type: [],
      printer_file: [],
      printer_model: []
    ]
    # add new user profile fields from yaml
    profile_metadata_fields.each do |field, _type|
      existing_permit_list << field.to_sym
    end
    params.require(:user).permit(existing_permit_list)
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
