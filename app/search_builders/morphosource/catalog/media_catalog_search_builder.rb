class Morphosource::Catalog::MediaCatalogSearchBuilder < Hyrax::CatalogSearchBuilder
  # override filter_collection_facet_for_access
  include Morphosource::Facets::CollectionsSearchBuilderBehavior

  # organization members can view all organization media
  # other users can view media they have permission to view
  def add_access_controls_to_solr_params(solr_parameters)
    solr_parameters[:fq] ||= []
    byebug
    solr_parameters[:fq] << gated_discovery_filters.reject(&:blank?).join(' OR ')
    byebug
    Rails.logger.debug("Solr parameters: #{solr_parameters.inspect}")
  end

  # retrieve media for current_user's organizations
  def apply_organization_permissions(permission_types, ability = current_ability)
    groups = ability.user_groups
    roles = ['_managers','_editors','_downloaders','_viewers']
    groups.select!{|group| roles.any? { |role| group.include?(role) } }
    return [] if groups.empty?
    byebug
    field = 'media_organization_id_ssim'
    collection_ids = groups.map{|group| group.split('_').first}
    ["({!terms f=#{field}}#{collection_ids.join(',')})"]
  end

  private

    def models
      [::Media]
    end

    def solr_access_filters_logic
      super << :apply_organization_permissions
    end
end
