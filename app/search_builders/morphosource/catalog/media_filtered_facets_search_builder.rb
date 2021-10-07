class Morphosource::Catalog::MediaFilteredFacetsSearchBuilder < Hyrax::CatalogSearchBuilder

  self.default_processor_chain += [:apply_collection_ids_filter]



  private

    def models
      [::Media]
    end

    def apply_collection_ids_filter(solr_parameters)
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << collection_ids_filter
    end

    def object_ids_filter
      "(id:(#{member_of_collection_ids_ssim.join(' OR ')}))"
    end

    def collection_ids
      byebug
      []
    end

    def my_media_object_ids
      repository.blacklight_config.max_per_page = 999999
      repository.search(Morphosource::Users::MyMediaObjectsSearchBuilder.new(@scope).rows(999999).query).response['docs'].map { |d| d["physical_object_id_ssim"].try(:first) }.compact
    end

end
