class Morphosource::Catalog::MediaCatalogSearchBuilder < Morphosource::Catalog::CatalogSearchBuilder
  
  private

    def models
      [::Media]
    end

    def collection_facet
      'member_of_collection_ids_ssim'
    end

    # Keeping this here for now, may want to benchmark regex vs array

    # def collection_ids_regexp(collection_ids)
    #   collection_ids.map! { |id| "^#{id}$" }
    #   if collection_ids.present?
    #     collection_ids.join('|')
    #   else
    #     "^$"
    #   end
    # end

end
