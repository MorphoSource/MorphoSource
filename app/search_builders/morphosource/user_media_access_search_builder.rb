module Morphosource
  class UserMediaAccessSearchBuilder < Hyrax::SearchBuilder

    self.default_processor_chain = [:filter_models]

    # include Hyrax::SearchFilters

    # TODO: move this to Hydra::AccessControlsEnforcement
    # @param access [String] what access level to set. Either 'read' or 'edit'
    # @return [SearchBuilder]
    # def with_access(access)
    #   @discovery_permissions = Array.wrap(access)
    #   self
    # end

    # Override Hydra::AccessControlsEnforcement (or Hydra::PolicyAwareAccessControlsEnforcement)
    # Allows admin users to see everything (don't apply any gated_discovery_filters for those users)
    # def gated_discovery_filters(permission_types = discovery_permissions, ability = current_ability)
    #   return [] if ability.admin?
    #   super
    # end

    # def shared_view_works
    #
    # end

    def models
      byebug
      [Media]
    end

    # def user_read_groups
    #   current_user.roles.map{|r| r.name if r.name.include? 'viewers' }
    # end
    #
    # def user_edit_groups
    # end

    # def filter_public(solr_parameters)
    #   solr_parameters[:fq] ||= []
    #   solr_parameters[:fq] << "{!terms f=has_model_ssim}#{models_to_solr_clause}"
    # end

    # def find_media
    #   h = Hash[user_read_groups.collect { |v| ['read_access_group_ssim', v] }]
    #   qry = assemble_query(h)
    #   search_solr(qry)
    # end
    #
    # def assemble_query(specific_params)
    #   query_clauses = param_clauses(specific_params)
    #   query_clauses.join(' OR ')
    # end
    #
    # def param_clauses(specific_params)
    #   clauses = []
    #   specific_params.each do |k,v|
    #     clauses << "#{Solrizer.solr_name(k, :symbol)}:#{prepare_value(v)}"
    #   end
    #   clauses
    # end

  end
end
