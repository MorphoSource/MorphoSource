class Morphosource::Catalog::MediaCatalogSearchBuilder < Hyrax::CatalogSearchBuilder

  private

    def models
      [::Media]
    end

    # only return facet counts for collections that this user has access to see
  def filter_collection_facet_for_access(solr_parameters)
    # return if current_ability.admin?
    byebug
    collection_ids = Hyrax::Collections::PermissionsService.collection_ids_for_view(ability: current_ability).map { |id| "^#{id}$" }
    # solr_parameters['f.member_of_collection_ids_ssim.facet.matches'] = if collection_ids.present?
    #                                                                      collection_ids.join('|')
    #                                                                    else
    #                                                                      "^$"
    #                                                                    end
   solr_parameters['f.member_of_collection_ids_ssim.facet.contains'] = "000203044"
  end

end
