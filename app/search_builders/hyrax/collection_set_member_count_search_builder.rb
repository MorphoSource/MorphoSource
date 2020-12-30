module Hyrax
  class CollectionSetMemberCountSearchBuilder < ::SearchBuilder
    include Hyrax::FilterByType
    attr_reader :access, :search_includes_models, :ids

    self.default_processor_chain += [:filter_on_ids]

	  def initialize(scope:,
                   search_includes_models: :works,
                   ids:)
	    @ids = ids
      @search_includes_models = search_includes_models
	    super(scope)
	  end

	  def filter_on_ids(solr_parameters)
	    solr_parameters[:fq] ||= []
	    solr_parameters[:fq] += [
	      ::ActiveFedora::SolrQueryBuilder.construct_query(
	        {
	          id: @ids
	        },
	        join_with = ' OR '
	      )
	    ]
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
