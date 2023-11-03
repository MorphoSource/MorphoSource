class Morphosource::Catalog::MediaCatalogSearchBuilder < Hyrax::CatalogSearchBuilder
  include Morphosource::OrganizationalAccessBehavior
  # override filter_collection_facet_for_access
  include Morphosource::Facets::CollectionsSearchBuilderBehavior

  self.default_processor_chain += [:add_organizational_access_to_solr_params]

  # organization members can view all organization media
  # other users can view media they have permission to view
  # def add_access_controls_to_solr_params(solr_parameters)
  #   solr_parameters[:fq] ||= []
  #   solr_parameters[:fq] << gated_discovery_filters.reject(&:blank?).join(' OR ')
  #   Rails.logger.debug("Solr parameters: #{solr_parameters.inspect}")
  # end

  private

    def models
      [::Media]
    end

    # def solr_access_filters_logic
    #   byebug
    #   super << :apply_organization_permissions
    # end
end
