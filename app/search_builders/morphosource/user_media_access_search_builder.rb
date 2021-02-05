module Morphosource
  class UserMediaAccessSearchBuilder < Hyrax::SearchBuilder

    # [:default_solr_parameters, :add_query_to_solr, :add_facet_fq_to_solr, :add_facetting_to_solr, :add_solr_fields_to_query, :add_paging_to_solr, :add_sorting_to_solr, :add_group_config_to_solr, :add_facet_paging_to_solr, :add_access_controls_to_solr_params, :filter_models, :only_active_works]

    # self.default_processor_chain += [:gated_discovery_filters]

    # include Hyrax::SearchFilters

    # TODO: move this to Hydra::AccessControlsEnforcement
    # @param access [String] what access level to set. Either 'read' or 'edit'
    # @return [SearchBuilder]
    def with_access(access)
      @discovery_permissions = Array.wrap(access)
      self
    end

    # Override Hydra::AccessControlsEnforcement (or Hydra::PolicyAwareAccessControlsEnforcement)
    # Allows admin users to see everything (don't apply any gated_discovery_filters for those users)
    def gated_discovery_filters(permission_types = discovery_permissions, ability = current_ability)
      return [] if ability.admin?
      super
    end

    def models
      byebug
      [Media]
    end

  end
end
