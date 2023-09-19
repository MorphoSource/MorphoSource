module Morphosource
  module UserProfileBehavior

    def valid_profile_types
      @valid_profile_types ||= profile_type_config.keys - [:universal]
    end


    private

    def profile_type_config
      yaml_data = YAML.load_file(Rails.root.join('config', 'models', 'user_profile_types.yml'))
      yaml_data['profile_types']
    end

    def check_profile_type
      unless profile_type_valid?
        errors.add(:base, "Profile type not valid")
      end
      unless metadata_match_profile_type?
        errors.add(:base, "Metadata does not match profile type")
      end
    end

    def metadata_match_profile_type?
      accepted_fields = profile_type_config[profile_type]['metadata_fields']
      unaccepted_fields = non_universal_metadata_fields.uniq - [accepted_fields]
      unaccepted_fields.each do |field|
        if self.respond_to?(field)
          if self.send(field).present?
Rails.logger.debug("#{field} cannot be present for profile type #{profile_type}")
            errors.add(:base, "#{field} cannot be present for profile type #{profile_type}")
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
      valid_profile_types.include?(profile_type)
    end

  end
end