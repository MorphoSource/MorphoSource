module Morphosource
  module Dashboard
    module ProfilesControllerBehavior

      def valid_profile_types
        @valid_profile_types ||= profile_type_config.values.map { |profile| profile['label'] }.compact
      end


      private

      def user_params
        @user_params ||= params[:user]
      end

      def profile_type
        @profile_type ||= user_params[:profile_type]
        # @user.profile_type
      end

      def profile_type_config
        @profile_type_config ||= Hyrax.config.user_profile_type_config
      end

      def profile_metadata_fields
        @profile_metadata_fields ||= Hyrax.config.user_profile_metadata_fields
      end

      def check_profile_type
        unless user_mapped_profile_type.present?
          redirect_with_error("Profile type not valid")
          return false
        end
        @errors = []
        check_metadata_match_profile_type
        validate_field_values
        redirect_with_error(@errors) if @errors.present?        
      end

      def profile_type_by_label(value)
        return nil unless value.present?
        profile_type_config.each do |profile_type, data|
          if data['label'] == value
            return profile_type
          end
        end
       return nil
      end

      def validate_field_values
        # check required_metadata_fields for both universal and the user profile type
        required_fields = profile_type_config["universal"]['required_metadata_fields'].split(', ')
        if (prof_type_required_fields = profile_type_config[user_mapped_profile_type]['required_metadata_fields']).present?
          required_fields += prof_type_required_fields.split(', ')
        end
        required_fields.each do |field|
          if user_params.has_key?(field)
            unless user_params[field].present?
              @errors << "#{translated(field)} is required"
            end
          end
        end
      end

      def user_mapped_profile_type
        @user_mapped_profile_type ||= profile_type_by_label(profile_type)
      end

      def check_metadata_match_profile_type
        accepted_fields = []
        if profile_type_config[user_mapped_profile_type]['metadata_fields'].present?
          accepted_fields << profile_type_config[user_mapped_profile_type]['metadata_fields'].split(', ')
        end
        if profile_type_config[user_mapped_profile_type]['required_metadata_fields'].present?
          accepted_fields << profile_type_config[user_mapped_profile_type]['required_metadata_fields'].split(', ')
        end
        unaccepted_fields = non_universal_metadata_fields.uniq - accepted_fields.flatten
        unaccepted_fields.each do |field|
          if user_params.has_key?(field)
            if user_params[field].present?
              @errors << "#{translated(field)} cannot be present for profile type #{profile_type}"
            end
          end
        end
      end

      def translated(field)
        if I18n.exists?("morphosource.dashboard.profiles.edit_primary.#{field}")
          t("morphosource.dashboard.profiles.edit_primary.#{field}").html_safe
        else
          field
        end
      end

      def non_universal_metadata_fields
        fields = []
        profile_type_config.each do |prof_type, data|
          if prof_type != 'universal'
            if data['metadata_fields']
              fields += data['metadata_fields'].split(', ')
            end
            if data['required_metadata_fields']
              fields += data['required_metadata_fields'].split(', ')
            end
          end
        end
        return fields
      end

      def redirect_with_error(messages)
        flash[:error] = messages
        redirect_to hyrax.dashboard_profile_path(@user.to_param)
      end

    end
  end
end