module Morphosource
  module UserProfileBehavior

    def valid_profile_types
      @valid_profile_types ||= profile_type_config.values.map { |profile| profile['label'] }.compact
    end


    private

    def profile_type_config
      yaml_data = YAML.load_file(Rails.root.join('config', 'models', 'user_profile_types.yml'))
      yaml_data['profile_types']
    end

    def check_profile_type
      unless profile_type_valid?
        add_error("Profile type not valid")
      end
      unless metadata_match_profile_type?
        add_error("Metadata does not match profile type")
      end
    end

    def profile_type_by_label(value)
      profile_type_config.each do |profile_type, data|
        if data['label'] == value
          return profile_type
        end
      end
     return nil
    end

    def metadata_match_profile_type?
      mapped_profile_type = profile_type_by_label(profile_type)
      accepted_fields = []
      if profile_type_config[mapped_profile_type]['metadata_fields'].present?
        accepted_fields += [ profile_type_config[mapped_profile_type]['metadata_fields'] ]
      end
      if profile_type_config[mapped_profile_type]['required_metadata_fields'].present?
        accepted_fields += [ profile_type_config[mapped_profile_type]['required_metadata_fields'] ]
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
      valid_profile_types.include?(profile_type)
    end

    def add_error(msg)
      Rails.logger.debug(msg)
      errors.add(:base, msg)
    end

  end
end