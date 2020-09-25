class Morphosource::Catalog::ObjectsCatalogSearchBuilder < Morphosource::Catalog::CatalogSearchBuilder

  self.default_processor_chain += [
    :filter_media_facets_for_access
  ]

#   Media Type
#
# Media Team/Project
#
# Media Tag

  # only return facet counts for collections that this user has access to see
  def filter_media_facets_for_access(solr_parameters)
    return if current_ability.admin?
    if current_user
      media_ids = Morphosource::Catalog::Facets::MediaPermissionsService.ids_for_media_facets(ability: current_ability)
    else
      media_ids = Morphosource::Catalog::Facets::MediaPermissionsService.public_media_ids
    end
    # solr_parameters["f.media_type_sim.facet.matches"] = media_ids
    # solr_parameters["f.media_keyword_sim.facet.matches"] = media_ids
    solr_parameters["f.child_media_ids_ssim.facet.matches"] = media_ids
  end

  private

    def models
      [::BiologicalSpecimen, ::CulturalHeritageObject]
    end

    def collection_facet
      'media_member_of_collection_ids_ssim'
    end
end
