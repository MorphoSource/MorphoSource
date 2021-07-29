module Morphosource
  module Dashboard
    class ProfilesController < Hyrax::Dashboard::ProfilesController

      helper Morphosource::UserProfile::UserProfileHelper

      before_action :strip_empty_values, only: [:update]

      before_action :find_user, except: [:edit_password, :update_password]

      skip_authorize_resource only: [:edit_password, :update_password]

      def edit_password
        authenticate_user!
        @user = current_user
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb t(:'hyrax.admin.sidebar.profile'), hyrax.dashboard_profile_path
        render 'edit_password'
      end

      def update_password
        authenticate_user!
        @user = current_user
        if @user.update_with_password(update_password_params)
          bypass_sign_in(@user)
          redirect_to hyrax.dashboard_profile_path(@user.to_param), notice: "Your password has been updated"
        else
          redirect_to main_app.profile_edit_password_path(@user), alert: @user.errors.full_messages
        end
      end

      private

        def user_params
          params.require(:user).permit(:address, :affiliation, :sftp_share, :avatar, :country, :department, :display_name, :email, :facebook_handle, :linkedin_handle, :orcid, :postal_code, :remove_avatar, :state, :telephone, :terms_read, :twitter_handle, :website, demographics: [], software: [], intent: [], mesh_file_type: [], volume_file_type: [], printer_file: [], printer_model: [] )
        end

        def update_password_params
          params.require(:user).permit(:current_password, :password, :password_confirmation)
        end

        # Don't retain empty strings from 'other' fields.
        def strip_empty_values
          User::MULTI_VALUE_FIELDS.keys.each do |field|
            params[:user][field].delete_if(&:empty?)
          end
        end

    end
  end
end
