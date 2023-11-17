module Morphosource
  module Dashboard
    class ProfilesController < Hyrax::Dashboard::ProfilesController

      with_themed_layout :decide_layout
      helper Morphosource::UserProfile::UserProfileHelper
      include Morphosource::UserProfile::ProfileHelper

      before_action :find_user
      before_action :authenticate_user!
      before_action :authorize_edit, only: [:show]
      before_action :strip_empty_values, only: [:update]
      before_action :check_profile_type, only: [:update]
      authorize_resource class: '::User', instance_name: :user

      def show
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb t(:'hyrax.admin.sidebar.profile'), hyrax.dashboard_profile_path
        @presenter = Morphosource::UserProfilePresenter.new(@user, current_ability)
      end

      def edit
        @presenter = Morphosource::UserProfilePresenter.new(@user, current_ability)
        super
      end

      def edit_profile_type          
        @presenter = Morphosource::UserProfilePresenter.new(@user, current_ability)
        render 'edit_profile_type'
      end

      def edit_password
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb t(:'hyrax.admin.sidebar.profile'), hyrax.dashboard_profile_path
        render 'edit_password'
      end

      # Process changes from profile form
      def update
        @presenter = Morphosource::UserProfilePresenter.new(@user, current_ability)
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
        if @user.update_with_password(update_password_params)
          bypass_sign_in(@user)
          redirect_to hyrax.dashboard_profile_path(@user.to_param), notice: "Your password has been updated"
        else
          redirect_to main_app.profile_edit_password_path(@user), alert: @user.errors.full_messages
        end
      end

      def generate_new_api_key
        @user.regenerate_token
        redirect_to main_app.profile_show_path, notice: "New API key has been generated."
      end


      private

        def authorize_edit
          authorize! :edit, @user
        end

        def user_params
          # todo: remove the following fields, and clean up later
          # Postal Code
          # Telephone
          # Software to view 3D
          # File Type for 3D Mesh
          # File Type for 3D Volume
          # 3D Printer Machine Type
          # 3D Printer File Type
          @user_params ||= begin
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
        end

        def update_password_params
          params.require(:user).permit(:current_password, :password, :password_confirmation)
        end

        # Don't retain empty strings from 'other' fields.
        def strip_empty_values
          User::MULTI_VALUE_FIELDS.keys.each do |field|
            if params[:user][field].present? 
              params[:user][field].delete_if(&:empty?)
            end
          end
        end

        def redirect_with_error(messages)
          flash[:error] = messages
          redirect_to hyrax.dashboard_profile_path(@user.to_param)
        end

        def decide_layout
          File.join(theme, ( action_name == 'edit_profile_type' ) ? 'morphosource_base' : 'morphosource_dashboard' )
        end

    end
  end
end
