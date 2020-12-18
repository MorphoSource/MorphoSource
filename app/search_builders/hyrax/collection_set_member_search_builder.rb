module Hyrax
  # This search builder requires that a accessor named "collection" exists in the scope
  class CollectionSetMemberSearchBuilder < ::SearchBuilder
    include Hyrax::FilterByType
    attr_reader :collections, :search_includes_models, :access

    class_attribute :collection_membership_field
    self.collection_membership_field = 'member_of_collection_ids_ssim'

    # Defines which search_params_logic should be used when searching for Collection members
    self.default_processor_chain += [:member_of_collection]

    # @param [scope] Typically the controller object
    # @param [Symbol] :works, :collections, (anything else retrieves both)
    def initialize(scope:,
                   collections:,
                   search_includes_models: :works)
      @collections = collections
      @search_includes_models = search_includes_models
      super(scope)
    end

    # include filters into the query to only include the collection memebers
    def member_of_collection(solr_parameters)
      solr_parameters[:fq] ||= []
      collection_ids = []
      collections.each do |collection_doc|
        collection_ids << collection_doc.id
      end
      solr_parameters[:fq] << "#{collection_membership_field}:(#{collection_ids.join(' OR ')})"
    end

    # This overrides the models in FilterByType
    def models
      case search_includes_models
      when :collections
        collection_classes
      when :works
        work_classes
      when :media
        [Media]
      when :physical_objects
        [BiologicalSpecimen,CulturalHeritageObject]
      else super # super includes both works and collections
      end
    end

    # Overrides Hydra::AccessControlsEnforcement
    def discovery_permissions
      @discovery_permissions = extract_discovery_permissions(@access)
    end

    def with_access(access)
      @access = access
      super(access)
    end

    private

      ACCESS_LEVELS_FOR_LEVEL = ActiveSupport::HashWithIndifferentAccess.new(
        edit: ["edit"],
        deposit: ["deposit"],
        read: ["edit", "read"],
        view: [Hyrax::PermissionTemplateAccess::MANAGE,
        Hyrax::PermissionTemplateAccess::EDIT_WORKS,
        Hyrax::PermissionTemplateAccess::DEPOSIT,
        Hyrax::PermissionTemplateAccess::DOWNLOAD_WORKS,
        Hyrax::PermissionTemplateAccess::VIEW]
      ).freeze

      def extract_discovery_permissions(access)
        access = :read if access.blank?
        ACCESS_LEVELS_FOR_LEVEL.fetch(access)
      end

  end
end
