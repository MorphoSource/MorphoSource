module Morphosource
  class UserProfilePresenter < Hyrax::UserProfilePresenter
    include ActionView::Helpers::NumberHelper
    include Morphosource::UserProfile::ProfileHelper

    attr_accessor :blacklight_config

    # returns the number of collections managed by @user viewable by @current_user
    def managed_collection_count
      byebug
      search_builder = Morphosource::Users::ManagedCollectionsSearchBuilder.new(self)
      repository.search(search_builder.query).response["numFound"]
    end

    # returns the number of media deposited by @user viewable by @current_user
    def deposited_media_count
      deposited_media_query_response["numFound"]
    end

    # returns the total file size (of files and derivatives) of media deposited by @user viewable by @current_user
    def deposited_media_filesize
      size_bytes = deposited_media_query_response["docs"].map { |doc| doc["all_files_file_size_lts"] }.compact.sum
      size_bytes == 0 ? "" : number_to_human_size(size_bytes)
    end

    # returns the number of media managed by @user viewable by @current_user
    def managed_media_count
      managed_media_query_response["numFound"]
    end

    # returns the total file size (of files and derivatives) of media managed by @user viewable by @current_user
    def managed_media_filesize
      size_bytes = managed_media_query_response["docs"].map { |doc| doc["all_files_file_size_lts"] }.compact.sum
      size_bytes == 0 ? "" : number_to_human_size(size_bytes)
    end

    def user
      @user
    end

    #
    # All metadata fields with mapped profile types
    #
    # @return [Hash] hash of: field => mapped profile types which has this field
    #
    def all_metadata_fields
      @all_metadata_fields ||= begin
        result_hash = {}
        sorted_metadata_fields.each do |field|
          matching_keys = find_keys_containing_field(field, :either)
          result_hash[field] = matching_keys unless matching_keys.empty?
        end
        result_hash
      end
    end

    #
    # Required fields with mapped profile types
    #
    # @return [Hash] hash of: field => mapped profile types with this field required
    #
    def required_metadata_fields
      @required_metadata_fields ||= begin
        required_fields = non_universal_metadata_fields(:required)
        result_hash = {}
        required_fields.each do |field|
          matching_keys = find_keys_containing_field(field, :required)
          result_hash[field] = matching_keys unless matching_keys.empty?
        end
        result_hash
      end
    end

    #
    # All demographics values with mapped profile types
    #
    # @return [Hash] hash of: demographic => mapped profile types associated with the demographic
    #
    def all_demographics_values
      @all_demographics_values ||= begin
        result_hash = {}
        user_demographics.each do |field|
          matching_keys = find_keys_containing_demographic(field)
          result_hash[field] = matching_keys unless matching_keys.empty?
        end
        result_hash
      end
    end

    #
    # Return name-specific fields to be displayed based on group / individual account
    #
    def name_fields
      user.profile_type == GROUP_PROFILE_TYPE ? ["display_name"] : [
        "first_name",
        "middle_name",
        "last_name"
      ]
    end

    #
    # Return a list of fields to be displayed on public user profile page
    #
    # @return [Array<String>] Field name
    #
    def display_fields_for_public
      display_fields - private_fields
    end

    #
    # Return a list of fields to be displayed on dashboard user profile page
    #
    # @return [Array<String>] Field name
    #
    def display_fields
      name_fields + [
        "email",
        "profile_type"
      ] + all_metadata_fields.keys + [
        "demographics",
        "intent",
        "address",
        "city",
        "state",
        "country",
        "orcid",
        "twitter_handle",
        "facebook_handle",
        "website"
      ]
    end

    #
    # Private Fields (fields that should not be shown to public) based on the user profile type
    #
    # @return [Array<String>] Field name
    #
    def private_fields
      @private_fields ||= begin
        fields = []
        profile_metadata_settings.each do |field, settings|
          next if settings.nil? || settings['private_for'].nil?
          private_for = settings['private_for']
          if private_for.include?("all") || private_for.include?(user.profile_type)
            fields << field
          end
        end
        fields
      end
    end

    alias current_ability ability

    def blacklight_config
      CollectionsCatalogController.blacklight_config
    end

    private

    def deposited_media_query_response
      @deposited_media_query_response ||= begin
        query = Morphosource::Users::DepositedMediaSearchBuilder.new(self).query.merge(
          'fl' => ['id', 'all_files_file_size_lts'],
          'rows' => 999_999
        )
        repository.search(query).response
      end
    end

    def managed_media_query_response
      @managed_media_query_response ||= begin
        query = Morphosource::Users::ManagedMediaSearchBuilder.new(self).query.merge(
          'fl' => ['id', 'all_files_file_size_lts'],
          'rows' => 999_999
        )
        repository.search(query).response
      end
    end

    #
    # Keys (profile types) which contain the specified field
    #
    # @param [String] field Metadata field name
    # @param [:required, :optional, :either] type Whether the field is required / optional / either
    #
    # @return [Array<String>] Keys matching the specified criteria
    #
    def find_keys_containing_field(field, type = :either)
      matching_keys = []
      profile_type_config.each do |prof_type, data|
        next if prof_type == 'universal'

        metadata_fields = data['metadata_fields'] || []
        required_metadata_fields = data['required_metadata_fields'] || []

        case type
        when :required
          if required_metadata_fields.include?(field)
            matching_keys << prof_type
          end
        when :optional
          if metadata_fields.include?(field)
            matching_keys << prof_type
          end
        else # :either
          if metadata_fields.include?(field) || required_metadata_fields.include?(field)
            matching_keys << prof_type
          end
        end
      end
      matching_keys
    end

    #
    # Keys (profile types) which contain the demographic field
    #
    # @param [String] field Demographic field name
    #
    # @return [Array<String>] Keys contain the specified field
    #
    def find_keys_containing_demographic(field)
      matching_keys = []
      profile_type_config.each do |prof_type, data|
        next if prof_type == 'universal'
        demographic_fields = data['demographics'] || []
        if demographic_fields.include?(field)
          matching_keys << prof_type
        end
      end
      matching_keys
    end

    def repository
      CatalogController.new.blacklight_config.repository
    end
  end
end