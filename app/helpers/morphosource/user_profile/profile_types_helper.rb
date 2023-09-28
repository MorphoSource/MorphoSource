module Morphosource::UserProfile::ProfileTypesHelper

  PROFILE_TYPES = {}
  # Iterate through the profile types and extract the labels
  Hyrax.config.user_profile_type_config.each do |profile_type, data|
    PROFILE_TYPES[data['label']] = data['label'] if data['label'].present?
  end

end
