module Morphosource
  module Dashboard
    module ProfilesControllerBehavior

      def valid_profile_types
        @valid_profile_types ||= profile_type_config.values.map { |profile| profile['label'] }.compact
      end


      private

      def profile_type
        @profile_type ||= params[:user][:profile_type]
        # @user.profile_type
      end

      def profile_type_config
        @profile_type_config ||= Hyrax.config.user_profile_type_config
      end

      def check_profile_type
   byebug 

#profile_type_valid is ???

        unless profile_type_valid?
          add_error("Profile type not valid")
          return false
        end
        unless metadata_match_profile_type?
          add_error("Metadata does not match profile type")
          return false
        end
        validate_field_values
      end

      def profile_type_by_label(value)
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
          if self.respond_to?(field)
            unless self.send(field).present?
              add_error("#{field} must be present")
            end
          end
        end
      end

      def user_mapped_profile_type
        @user_mapped_profile_type ||= profile_type_by_label(profile_type)
      end

      def metadata_match_profile_type?
        accepted_fields = []
        if profile_type_config[user_mapped_profile_type]['metadata_fields'].present?
          accepted_fields += [ profile_type_config[user_mapped_profile_type]['metadata_fields'] ]
        end
        if profile_type_config[user_mapped_profile_type]['required_metadata_fields'].present?
          accepted_fields += [ profile_type_config[user_mapped_profile_type]['required_metadata_fields'] ]
        end
        unaccepted_fields = non_universal_metadata_fields.uniq - accepted_fields
        unaccepted_fields.each do |field|
          if self.respond_to?(field)
            if self.send(field).present?
              add_error("#{field} cannot be present for profile type #{profile_type}")
            end
          end
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

      def profile_type_valid?
        #valid_profile_types.include?(profile_type)
        user_mapped_profile_type.present?
      end

      def add_error(msg)
        redirect_to hyrax.dashboard_profile_path(@user.to_param), notice: msg
      end

    end
  end
end