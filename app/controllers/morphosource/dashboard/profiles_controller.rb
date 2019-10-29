module Morphosource
  module Dashboard
    class ProfilesController < Hyrax::Dashboard::ProfilesController

      helper Morphosource::UserProfile::UserProfileHelper

      before_action :strip_empty_values, only: [:update]

      private

        def user_params
          params.require(:user).permit(:address, :affiliation, :avatar, :country, :department, :display_name, :email, :facebook_handle, :linkedin_handle, :orcid, :postal_code, :remove_avatar, :state, :telephone, :terms_read, :twitter_handle, :website, demographics: [], software: [], intent: [], mesh_file_type: [], volume_file_type: [], printer_file: [], printer_model: [] )
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
