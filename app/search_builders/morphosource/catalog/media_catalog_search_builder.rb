class Morphosource::Catalog::MediaCatalogSearchBuilder < Morphosource::CatalogSearchBuilder
  # override filter_collection_facet_for_access
  include Morphosource::Facets::CollectionsSearchBuilderBehavior
  # organization collection members can access that organization's media
  include Morphosource::OrganizationalAccessBehavior

  self.default_processor_chain += [:add_object_occurrence_id_filter]

  def add_object_occurrence_id_filter(solr_parameters)
    return unless (val = blacklight_params[:object_occurrence_id]).present?
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "occurrence_id_ssim:\"#{val.gsub('\\', '\\\\').gsub('"', '\\"')}\""
  end

  private

    def models
      [::Media]
    end
end
