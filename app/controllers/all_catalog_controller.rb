# Shows all work types and available facets
# Only accessible by admins, redirects to catalog/media for everyone else

class AllCatalogController < CatalogController

  def index
    redirect_to media_search_path unless current_user && current_user.admin?
    super
  end

  configure_blacklight do |config|
    # returns all work types
    config.search_builder_class = Hyrax::CatalogSearchBuilder

    # facet fields
    config.add_facet_field solr_name("human_readable_type", :facetable), label: "Work Type", limit: 5
    # media
    config.add_facet_field solr_name("human_readable_media_type", :symbol), label: "Media Type", limit: 5
    config.add_facet_field solr_name("media_modality", :symbol), label: "Media Modality", limit: 6
    config.add_facet_field solr_name("media_physical_object_type", :symbol), label: "Media Object Type", limit: 5
    config.add_facet_field solr_name("media_organization", :symbol), label: "Media Organization", limit: 5
    config.add_facet_field solr_name("keyword", :facetable), label: "Media Tag", limit: 5
    config.add_facet_field solr_name('member_of_collections', :symbol), label: 'Media Team / Project', limit: 5
    # objects
    config.add_facet_field solr_name("creator", :facetable), label: "Object Creator", limit: 5
    # organization
    config.add_facet_field "organization_ssim", label: "Object Organization", limit: 5
    # media types - human_readable_media_type for child   media
    # media collection
    config.add_facet_field solr_name("media_collections", :facetable), label: "Object Media Team / Project", limit: 5
    # media tag
    config.add_facet_field solr_name("media_keyword", :facetable), label: "Object Media Tag", limit: 5
    # organization
    # organization type
    config.add_facet_field solr_name("organization_type", :facetable), label: "Organization Type", limit: 5
    # team/project
    # linked organization (teams only)
    config.add_facet_field solr_name("linked_organization", :facetable), label: "Team Organization", limit: 5

  end
end
