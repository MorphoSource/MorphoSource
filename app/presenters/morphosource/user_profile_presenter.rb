module Morphosource
  class UserProfilePresenter < Hyrax::UserProfilePresenter
    include Morphosource::Users::ProfileHelper

    # returns the number of collections managed by @user viewable by @current_user
    def managed_collection_count
      search_builder = Morphosource::Users::ManagedCollectionsSearchBuilder.new(self)
      repository.search(search_builder.query).response["numFound"]
    end

    # returns the number of media deposited by @user viewable by @current_user
    def deposited_media_count
      search_builder = Morphosource::Users::DepositedMediaSearchBuilder.new(self)
      repository.search(search_builder.query).response["numFound"]
    end

    # returns the number of media managed by @user viewable by @current_user
    def managed_media_count
      search_builder = Morphosource::Users::ManagedMediaSearchBuilder.new(self)
      repository.search(search_builder.query).response["numFound"]
    end

    def user
      @user
    end

    # retruns a hash of: field => mapped profile types which has this field 
    def all_metadata_fields
      @all_metadata_fields ||= begin
        result_hash = {}
        sorted_metadata_fields.each do |field|
          matching_keys = find_keys_containing_field(field, :all)
          result_hash[field] = matching_keys unless matching_keys.empty?
        end
        result_hash
      end
    end

    # retruns a hash of: field => mapped profile types which this field (required)
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

    # retruns a hash of: demographic => mapped profile types associated with the demographic 
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


    private

      def find_keys_containing_field(field, type = :all)
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

      def repository
        catalog_controller = CatalogController.new
        catalog_controller.instance_variable_set(:@current_ability, @ability)
        catalog_controller.repository
      end
  end
end