# catalog/organizations
class OrganizationsCatalogController < CatalogController

  configure_blacklight do |config|
    config.search_builder_class = Morphosource::Catalog::OrganizationsCatalogSearchBuilder

    # facets
    # type of organization
    config.add_facet_field solr_name("organization_type", :facetable), label: "Type", limit: 5
  end
end
