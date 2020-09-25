class Morphosource::Catalog::CatalogSearchBuilder < Hyrax::CatalogSearchBuilder

  # only return facet counts for collections that this user has access to see
  def filter_collection_facet_for_access(solr_parameters)
    return if current_ability.admin?
    if current_user
      collection_ids = Morphosource::Catalog::Facets::CollectionsPermissionsService.ids_for_collection_facet(ability: current_ability)
    else
      collection_ids = Morphosource::Catalog::Facets::CollectionsPermissionsService.public_collection_ids
    end
    # solr_parameters['f.member_of_collection_ids_ssim.facet.matches'] = collection_ids_regexp(collection_ids)
    solr_parameters["f.#{collection_facet}.facet.matches"] = collection_ids
  end
end
