# this module is shared by ProfilesController and RegistrationsController
# mainly for validating and handling user profile type and related fields
module Morphosource
  module UserProfile
    module ProfilesBehavior

      def valid_profile_types
        @valid_profile_types ||= profile_type_config.values.map { |profile| profile['label'] }.compact
      end

      def required_fields_mappings
        # hash of mapped profile type => required metadata fields
        required_fields = {}
        profile_type_config.each do |key, config|
          required_metadata_fields = config["required_metadata_fields"]
          required_fields[key] = required_metadata_fields if required_metadata_fields
        end
        return required_fields
      end

      def field_to_profile_type_requiring
        # a hash of: field => mapped profile types which require this field



      end

#      def required_fields_by_profile_type(prof_type)
#        profile_type_config[prof_type]['required_metadata_fields']
#      end
      

      private

      def user_params
        @user_params ||= params[:user]
      end

      def profile_type
        @profile_type ||= user_params[:profile_type]
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
        required_fields.each do |field|
          if user_params.has_key?(field)
            unless user_params[field].present?
              @errors << "#{translated(field)} is required"
            end
          end
        end
        if (prof_type_required_fields = profile_type_config[user_mapped_profile_type]['required_metadata_fields']).present?
          prof_type_required_fields.split(', ').each do |field|
            if user_params.has_key?(field)
              unless user_params[field].present?
                @errors << "#{translated(field)} is required for profile type #{profile_type}"
              end
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

    end
  end
end