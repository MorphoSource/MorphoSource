module Morphosource
  module Dashboard
    class ProfilesController < Hyrax::Dashboard::ProfilesController

      with_themed_layout 'morphosource_dashboard'
      helper Morphosource::UserProfile::UserProfileHelper

      before_action :find_user, except: [:edit_password, :update_password, :generate_new_api_key]
      before_action :check_allowed_remote_source, :strip_empty_values, only: [:update]

      skip_authorize_resource only: [:edit_password, :update_password, :generate_new_api_key]

      def edit
        authenticate_user!
        unless current_user.admin? || @user == current_user
          render 'hyrax/base/unauthorized', status: :unauthorized
        end
        super
      end

      def edit_password
        authenticate_user!
        @user = current_user
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb t(:'hyrax.admin.sidebar.profile'), hyrax.dashboard_profile_path
        render 'edit_password'
      end

      # Process changes from profile form
      def update
        if conditionally_update
          handle_successful_update
          if @user.unconfirmed_email
            notice = "You must confirm your email to finish processing the change of email address. Please respond to the confirmation email sent to the new address, and then log out and log back in to MorphoSource."
            redirect_to hyrax.dashboard_profile_path(@user.to_param), notice: notice and return
          else
            redirect_to hyrax.dashboard_profile_path(@user.to_param), notice: "Your profile has been updated"
          end
        else
          redirect_to hyrax.edit_dashboard_profile_path(@user.to_param), alert: @user.errors.full_messages
        end
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

      def generate_new_api_key
        authenticate_user!
        @user = current_user
        @user.regenerate_token
        redirect_to main_app.profile_show_path, notice: "New API key has been generated."
      end

      def check_allowed_remote_source
        allowed_remote_source = request.params["user"]["allowed_remote_source"]
        return true unless allowed_remote_source.present?
        return true if allowed_remote_source.split(/\r\n/).all? { |s| is_valid_domain? s } 
        redirect_to hyrax.edit_dashboard_profile_path(@user.ms_id), alert: "Allowed Remote File Source URLs are invalid."
      end

      def is_valid_domain?(path)
        path.match? /^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,63}$/i 
      end

      private

        def user_params
          params.require(:user).permit(:address, :affiliation, :sftp_share, :allowed_remote_source, :avatar, :country, :department, :display_name, :email, :facebook_handle, :linkedin_handle, :orcid, :postal_code, :remove_avatar, :state, :telephone, :terms_read, :twitter_handle, :website, demographics: [], software: [], intent: [], mesh_file_type: [], volume_file_type: [], printer_file: [], printer_model: [] )
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
