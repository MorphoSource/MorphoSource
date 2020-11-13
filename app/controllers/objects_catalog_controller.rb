# catalog/objects
class ObjectsCatalogController < CatalogController

  configure_blacklight do |config|
    config.search_builder_class = Morphosource::Catalog::ObjectsCatalogSearchBuilder
    # disable thumbnails
    config.index.thumbnail_field = ''

    # facets
    # type facet (specimen or cho)
    config.add_facet_field solr_name("human_readable_type", :facetable), label: "Type", limit: 5
    # creator
    config.add_facet_field solr_name("creator", :facetable), label: "Creator", limit: 5
    # organization
    config.add_facet_field solr_name("organization", :facetable), label: "Organization", limit: 5
    # external taxonomy
    config.add_facet_field "external_taxonomy_tesim", label: "Taxonomy (GBIF)", limit: 25
    # media types
    config.add_facet_field "public_media_type_ssim", label: "Media Type", limit: 5
    # media tag
    config.add_facet_field "public_media_keyword_ssim", label: "Media Tag", limit: 5
    # media collection
    config.add_facet_field solr_name('media_member_of_public_collection_ids', :symbol), limit: 5, label: 'Media Team / Project', helper_method: :collection_title_by_id

    # search results display fields
    config.add_index_field solr_name("title", :stored_searchable), label: "Title", itemprop: 'name', if: false
    config.add_index_field solr_name("taxonomy", :stored_searchable), label: "Taxonomy"
    config.add_index_field solr_name("organization", :stored_searchable), label: "Organization"
    config.add_index_field solr_name("human_readable_type", :stored_searchable), label: "Type"
    # do not show if object is a cho
    # defined on the solr document model at Morphosource::SolrDocumentBehavior
    config.add_index_field 'source', accessor: 'object_record_source', if: lambda { |context, field_config, document|
      document.specimen?
    }
    # media count displayed from _index_list_default
    # method total_viewable_media in Morphosource::PresenterMethods
  end
end
