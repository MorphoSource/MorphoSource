# catalog/organizations
class OrganizationsCatalogController < CatalogController

  configure_blacklight do |config|
    config.search_builder_class = Morphosource::Catalog::OrganizationsCatalogSearchBuilder
    # disable thumbnails
    config.index.thumbnail_field = ''

    # facets
    # type of organization
    config.add_facet_field solr_name("organization_type", :facetable), label: "Type", limit: 5
    # institution
    config.add_facet_field solr_name("institution_name", :facetable), label: "Institution", limit: 5
    # institution code
    config.add_facet_field "institution_code_tesim", label: "Institution Code", limit: 5
    # country
    config.add_facet_field "country_tesim", label: "Country", limit: 5
    # state_province
    config.add_facet_field "state_province_tesim", label: "State / Province", limit: 5
    # city
    config.add_facet_field "city_tesim", label: "City", limit: 5

    # search results display fields
    config.add_index_field solr_name("organization_type", :stored_searchable), label: "Type"
    config.add_index_field solr_name("title", :stored_searchable), label: "Title", itemprop: 'name', if: false
    config.add_index_field solr_name("institution_name", :stored_searchable), label: "Institution"
    config.add_index_field solr_name("institution_code", :stored_searchable), label: "Institution Code"
    config.add_index_field solr_name("collection_code", :stored_searchable), label: "Collection Code"
    config.add_index_field solr_name("country", :stored_searchable), label: "Country"
    # linked team displayed from _index_list_default
    # method linked_team in Hyrax::OrganizationPresenter
  end
end
