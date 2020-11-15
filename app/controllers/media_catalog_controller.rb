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

    # Search Results Fields
    config.add_index_field solr_name("title", :stored_searchable), label: "Title", itemprop: 'name', if: false
    config.add_index_field solr_name("physical_object_id", :stored_searchable), label: "Object", helper_method: :link_to_object
    config.add_index_field solr_name("taxonomy", :stored_searchable), label: "Taxonomy"
    config.add_index_field solr_name("part", :stored_searchable), label: "Element or Part"
    config.add_index_field solr_name("media_modality", :stored_searchable), label: "Modality"
    config.add_index_field solr_name("depositor"), label: "Owner", helper_method: :link_to_profile
    config.add_index_field solr_name("date_uploaded", :stored_sortable, type: :date), label: 'Date Uploaded', helper_method: :human_readable_date
    config.add_index_field solr_name("rights_statement", :stored_searchable), helper_method: :rights_statement_links
  end
end
