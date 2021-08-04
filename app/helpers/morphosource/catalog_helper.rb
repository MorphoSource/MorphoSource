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

  # media index metadata displays title linked to physical object
  def link_to_object(args)
    id = args[:document]["physical_object_id_tesim"].first
    object = SolrDocument.find(id)
    title = object.title.first
    if object.specimen?
      link_to title, specimen_showcase_path(object)
    else
      link_to title, cho_showcase_path(object)
    end
  end

  # based on link_to_profile
  # https://github.com/samvera/hyrax/blob/v2.9.0/app/helpers/hyrax/hyrax_helper_behavior.rb
  def link_to_user_with_ownership(args)
    user_key = args[:document].user_with_ownership
    return if user_key.nil?

    user = ::User.find_by(ms_id: user_key.first)
    return user_key.first if user.nil?

    link_to user.name, Hyrax::Engine.routes.url_helpers.user_path(user)
  end
end
