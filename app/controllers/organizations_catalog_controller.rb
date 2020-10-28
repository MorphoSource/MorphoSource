# catalog/organizations
class OrganizationsCatalogController < CatalogController

  configure_blacklight do |config|
    config.search_builder_class = Morphosource::Catalog::OrganizationsCatalogSearchBuilder
    
    # facets
    # type of organization
    config.add_facet_field solr_name("organization_type", :facetable), label: "Type", limit: 5
    # institution
    config.add_facet_field solr_name("institution_name", :facetable), label: "Institution Name", limit: 5
    # institution code
    config.add_facet_field "institution_code_tesim", label: "Institution Code", limit: 5
    # collection code
    config.add_facet_field solr_name("collection_code", :facetable), label: "Collection Code", limit: 5
  end
end
