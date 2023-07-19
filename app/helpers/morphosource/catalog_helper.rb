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

    link_to user.name_or_email, Hyrax::Engine.routes.url_helpers.user_path(user)
  end

  # Blacklight index field helper_method to determine field visibility based on permissions
  # @param config [Blacklight::Configuration] BL config where config.key should map to solr field
  # @param document [SolrDocument] Solr doc where field should map to array of document ID(s)
  # @return [Boolean] whether any of the document IDs can be viewed
  def can_read_any(config, document)
    ( document[config[:key]] || [] ).any? { |id| can? :read, id }
  end

  # media index metadata displays sequential section list titles with links
  def link_to_sequential_section_lists(args)
    return if !args[:value].present?
    links = args[:value].map do |id|
      if can? :read, id
        link_to collection_title_by_id(id), sequential_section_list_path(id)
      end
    end.compact
    return if !links.present?
    links.join(", ").html_safe
  end

  # Blacklight facet field helper_method for license controlled vocabulary
  # @param value [String] value that conforms to a license CV ID
  # @return [String] license human-readable label
  def license_title_by_id(value)
    Hyrax.config.license_service_class.new.label(value)
  end

  # Blacklight facet field helper_method for rights statement controlled vocabulary
  # @param value [String] value that conforms to a rights statement CV ID
  # @return [String] license human-readable label
  def rights_statement_title_by_id(value)
    Hyrax.config.rights_statement_service_class.new.label(value)
  end
end
