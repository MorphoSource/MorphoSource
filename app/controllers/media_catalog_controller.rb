# catalog/media
# default catalog view
# catalog/all redirects here for non-admins
class MediaCatalogController < CatalogController

  configure_blacklight do |config|
    config.search_builder_class = Morphosource::Catalog::MediaCatalogSearchBuilder

    # facet fields
    # type
    config.add_facet_field solr_name("human_readable_media_type", :facetable), label: "Type", limit: 5
    # modality - inherited from imaging event modality
    config.add_facet_field solr_name("media_modality", :facetable), label: "Modality", limit: 6
    # object type - specimen or cho
    config.add_facet_field solr_name("media_physical_object_type", :facetable), label: "Object Type", limit: 5
    # organization that owns the object
    config.add_facet_field solr_name("media_organization", :facetable), label: "Organization", limit: 5
    # tags
    config.add_facet_field solr_name("keyword", :facetable), label: "Tag", limit: 5
    # project/team
    # config.add_facet_field solr_name('member_of_collection_ids', :symbol), limit: 5, label: 'Team / Project', helper_method: :collection_title_by_id
    config.add_facet_field solr_name('member_of_public_collection_ids', :symbol), limit: 5, label: 'Team / Project', helper_method: :collection_title_by_id
  end
end
