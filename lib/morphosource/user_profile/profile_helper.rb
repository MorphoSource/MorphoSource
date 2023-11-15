module Morphosource::UserProfile::ProfileHelper

  PROFILE_TYPES = {}
  # Iterate through the profile types and extract the labels
  Hyrax.config.user_profile_type_config.each do |profile_type, data|
    PROFILE_TYPES[data['label']] = data['label'] if data['label'].present?
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

  def profile_metadata_settings
    @profile_metadata_settings ||= Hyrax.config.user_profile_metadata_settings
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

  def sorted_metadata_fields
    @sorted_metadata_fields ||=  begin 
      non_universal_fields = non_universal_metadata_fields
      # sort all_fields based on the metadata fields yaml
      non_universal_fields.sort_by { |field| profile_metadata_fields.keys.index(field) || profile_metadata_fields.keys.length }
    end
  end

  #
  # Non-universal metadata fields
  #
  # @param [:required, :optional, :either] type Whether the field is required / optional / either
  #
  # @return [Array<String>] Fields matching the specified type
  #
  def non_universal_metadata_fields(type = :either)
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
