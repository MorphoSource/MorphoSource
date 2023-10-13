# this module is shared by ProfilesController and RegistrationsController
# mainly for validating and handling user profile type and related fields
module Morphosource
  module UserProfile
    module ProfilesBehavior

      def valid_profile_types
        @valid_profile_types ||= profile_type_config.values.map { |profile| profile['label'] }.compact
      end

      def find_keys_containing_field(field, type = :all)
        matching_keys = []
        profile_type_config.each do |prof_type, data|
          next if prof_type == 'universal'

          metadata_fields = data['metadata_fields']
          required_metadata_fields = data['required_metadata_fields']

          case type
          when :required
            if required_metadata_fields.include?(field)
              matching_keys << prof_type
            end
          when :optional
            if metadata_fields.include?(field)
              matching_keys << prof_type
            end
          else
            if metadata_fields.include?(field) || required_metadata_fields.include?(field)
              matching_keys << prof_type
            end
          end
        end
        matching_keys
      end

      def find_keys_containing_demographic(field)
        matching_keys = []
        profile_type_config.each do |prof_type, data|
          next if prof_type == 'universal'
          demographic_fields = data['demographics']
          if demographic_fields.include?(field)
            matching_keys << prof_type
          end
        end
        matching_keys
      end

      def sorted_metadata_fields
        @sorted_metadata_fields ||=  begin 
          all_fields = non_universal_metadata_fields(:all)
          # sort all_fields based on the metadata fields yaml
          all_fields.sort_by { |field| profile_metadata_fields.keys.index(field) || profile_metadata_fields.keys.length }
        end
      end

      def all_metadata_fields_hash
        # retruns a hash of: field => mapped profile types which has this field 
        result_hash = {}
        sorted_metadata_fields.each do |field|
          matching_keys = find_keys_containing_field(field, :all)
          result_hash[field] = matching_keys unless matching_keys.empty?
        end
        return result_hash
      end

      def required_metadata_fields_hash
        # retruns a hash of: field => mapped profile types which this field (required)
        required_fields = non_universal_metadata_fields(:required)
        result_hash = {}
        required_fields.each do |field|
          matching_keys = find_keys_containing_field(field, :required)
          result_hash[field] = matching_keys unless matching_keys.empty?
        end
        return result_hash
      end

      def all_demographics_values_hash
        # retruns a hash of: demographic => mapped profile types associated with the demographic 
        result_hash = {}
        user_demographics.each do |field|
          matching_keys = find_keys_containing_demographic(field)
          result_hash[field] = matching_keys unless matching_keys.empty?
        end
        return result_hash
      end

      
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

      def user_demographics
        @user_demographics ||= Hyrax.config.user_demographics
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
        required_fields = profile_type_config["universal"]['required_metadata_fields']
        required_fields.each do |field|
          if user_params.has_key?(field)
            unless user_params[field].present?
              @errors << "#{translated(field)} is required"
            end
          end
        end
        if (prof_type_required_fields = profile_type_config[user_mapped_profile_type]['required_metadata_fields']).present?
          prof_type_required_fields.each do |field|
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
          accepted_fields << profile_type_config[user_mapped_profile_type]['metadata_fields']
        end
        if profile_type_config[user_mapped_profile_type]['required_metadata_fields'].present?
          accepted_fields << profile_type_config[user_mapped_profile_type]['required_metadata_fields']
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

      def non_universal_metadata_fields(type = :all)
        fields = []
        profile_type_config.each do |prof_type, data|
          if prof_type != 'universal'
            unless type == :required
              if data['metadata_fields']
                fields += data['metadata_fields']
              end
            end
            unless type == :optional
              if data['required_metadata_fields']
                fields += data['required_metadata_fields']
              end
            end
          end
        end
        return fields.uniq
      end

    end
  end
end