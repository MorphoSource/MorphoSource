module Morphosource
  class PhysicalObjectMediaSearchBuilder < ::SearchBuilder
    include Hyrax::FilterByType
    attr_reader :object_id

    class_attribute :object_id_field
    self.object_id_field = 'physical_object_id_ssim'

    self.default_processor_chain += [:represents_object]

    def initialize(scope:,
                   object_id:)
      @object_id = object_id
      super(scope)
    end

    def represents_object(solr_parameters)
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << "#{object_id_field}:#{object_id}"
    end

    # organization members can view all organization media
    # other users can view media they have permission to view
    def add_access_controls_to_solr_params(solr_parameters)
      solr_parameters[:fq] ||= []
      unless user_is_organization_member?
        solr_parameters[:fq] << gated_discovery_filters.reject(&:blank?).join(' OR ')
      end
      Rails.logger.debug("Solr parameters: #{solr_parameters.inspect}")
    end

    def user_is_organization_member?
      return false unless current_user
      return false unless organization_id = SolrDocument.find(@object_id)['organization_id_ssim']&.first

      organization_user_groups = OrganizationCollection::DEFAULT_GROUP_ROLES.map{|role| "#{organization_id}_#{role}"}
      (organization_user_groups & current_user.groups).present?
    end

    # This overrides the models in FilterByType
    def models
      [Media]
    end

    # Overrides Hydra::AccessControlsEnforcement
    def discovery_permissions
       ["edit","download","read"]
    end
  end
end
