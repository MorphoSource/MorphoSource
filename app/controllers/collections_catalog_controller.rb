# catalog/teams_projects
class CollectionsCatalogController < CatalogController

  configure_blacklight do |config|
    config.search_builder_class = Morphosource::Catalog::CollectionsCatalogSearchBuilder
    # display thumbnails in search results
    config.index.thumbnail_field = 'thumbnail_path_ss'

    # facets
    # type facet (team or project)
    config.add_facet_field solr_name("human_readable_type", :facetable), label: "Type", limit: 5
    # linked organization
    config.add_facet_field solr_name("linked_organization", :facetable), label: "Organization", limit: 5

    # search result metadata
    config.add_index_field solr_name("title", :stored_searchable), label: "Title", itemprop: 'name', if: false
    config.add_index_field solr_name("depositor", :stored_searchable), label: "Creator", helper_method: :link_to_profile
    config.add_index_field 'collection_member_count', accessor: 'collection_member_count', label: "Number of Members"
    # for some reason the label is not getting rendered correctly in the catalog. For now, overriding in _index_list_default
    config.add_index_field solr_name("date_uploaded", :stored_sortable, type: :date), label: "Date Created", helper_method: :human_readable_date
  end
end
