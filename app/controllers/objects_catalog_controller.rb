# catalog/objects
class ObjectsCatalogController < CatalogController

  configure_blacklight do |config|
    config.search_builder_class = Morphosource::Catalog::ObjectsCatalogSearchBuilder

    # facets
    # type facet (specimen or cho)
    config.add_facet_field solr_name("human_readable_type", :facetable), label: "Type", limit: 5
    # creator
    config.add_facet_field solr_name("creator", :facetable), label: "Creator", limit: 5
    # organization
    config.add_facet_field solr_name("organization", :facetable), label: "Organization", limit: 5
    # media types
    config.add_facet_field solr_name("human_readable_media_type", :facetable), label: "Media Type", limit: 5
    # media collection
    config.add_facet_field solr_name("media_collections", :facetable), label: "Media Team / Project", limit: 5
    # media tag
    config.add_facet_field solr_name("media_keyword", :facetable), label: "Media Tag", limit: 5

  end

end
