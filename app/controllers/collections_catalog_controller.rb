# catalog/teams_projects
class CollectionsCatalogController < CatalogController

  configure_blacklight do |config|
    config.search_builder_class = Morphosource::Catalog::CollectionsCatalogSearchBuilder

    # facets
    # type facet (team or project)
    config.add_facet_field solr_name("human_readable_type", :facetable), label: "Type", limit: 5
    # linked organization
    config.add_facet_field solr_name("linked_organization", :facetable), label: "Organization", limit: 5
  end
end
