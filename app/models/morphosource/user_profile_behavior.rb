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
    end
    
    def profile_type_valid?
      valid_profile_types.include?(profile_type)
    end

  end
end