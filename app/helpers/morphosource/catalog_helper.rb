module Morphosource::CatalogHelper

  # used by the ms_catalog_refine_search_form
  # sets the search path to whatever the current work type is
  def catalog_search_path
    case controller_name
    when "media_catalog"
      main_app.media_search_path
    when "organizations_catalog"
      main_app.organization_search_path
    when "objects_catalog"
      main_app.object_search_path
    when "collections_catalog"
      main_app.collection_search_path
    when "all_catalog"
      main_app.all_search_path
    else
      search_form_action
    end
  end

  def media_type_by_id(id)
    solr_docs = controller.repository.find(id).docs
    return nil if solr_docs.empty?
    solr_field = solr_docs.first["human_readable_media_type_tesim"]
    return nil if solr_field.nil?
    solr_field.first
  end
end
