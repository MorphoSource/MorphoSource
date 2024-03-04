class Morphosource::Catalog::OrganizationsCatalogSearchBuilder < Morphosource::CatalogSearchBuilder

  def add_query_to_solr(solr_parameters)
    byebug
    super
  end

  private

    def models
      [::Organization, ::OrganizationCollection]
    end
end
