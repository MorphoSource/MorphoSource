module Morphosource::CatalogHelper
  # ensure Taxonomy names are in italics
  def italicize_taxonomy(args)
    args[:value].map do |value|
      tag.div(tag.i(sanitize(value)))
    end.join.html_safe
  end

  # media index metadata displays title linked to physical object
  def link_to_object(args)
    return nil unless args[:document]["physical_object_id_tesim"].present?

    title = args[:document]["physical_object_title_tesim"]&.first || "Object Title Unknown"
    if args[:document]["media_physical_object_type_tesim"]&.first == "Biological Specimen"
      link_to title, specimen_showcase_path(args[:document]["physical_object_id_tesim"]&.first)
    elsif args[:document]["media_physical_object_type_tesim"]&.first == "Cultural Heritage Object"
      link_to title, cho_showcase_path(args[:document]["physical_object_id_tesim"]&.first)
    end
  end

  def link_to_user_with_ownership(args)
    return nil unless args[:value].present?

    display_name = args[:document]["user_with_ownership_name_tesim"]&.first || "User Name Unknown"
    if args[:document][:owner_type_ssi] == "OrganizationCollection"
      link_to display_name, main_app.organization_path(args[:value]&.first)
    else
      link_to display_name, Hyrax::Engine.routes.url_helpers.user_path(args[:value]&.first)
    end
  end

  # Blacklight index field helper_method to determine field visibility based on permissions
  # @param config [Blacklight::Configuration] BL config where config.key should map to solr field
  # @param document [SolrDocument] Solr doc where field should map to array of document ID(s)
  # @return [Boolean] whether any of the document IDs can be viewed
  def can_read_any(config, document)
    ( document[config[:key]] || [] ).any? { |id| can? :read, id }
  end

  # override helper method from Blacklight to work with facet fields where field != key
  # @param [String] field Solr facet name
  # @return [Blacklight::Configuration::FacetField] Blacklight facet configuration for the solr field
  def facet_configuration_for_field(field)
    blacklight_config.facet_fields[field] || super(field)
  end

  def modalities_service_instance
    @modalities_service_instance ||= Morphosource::ModalitiesService.new
  end

  def modality_label_by_id(id)
    modalities_service_instance.label(id) { "Modality Not Found" }
  end

  # media index metadata displays sequential section list titles with links
  def link_to_sequential_section_lists(args)
    return if !args[:value].present?
    links = args[:value].map do |id|
      if can? :read, id
        link_to title_by_id(id), sequential_section_list_path(id)
      end
    end.compact
    return if !links.present?
    links.join(", ").html_safe
  end

  def license_service_instance
    @license_service_instance ||= Hyrax.config.license_service_class.new
  end

  # Blacklight facet field helper_method for license controlled vocabulary
  # @param value [String] value that conforms to a license CV ID
  # @return [String] license human-readable label
  def license_title_by_id(value)
    license_service_instance.label(value)
  end

  def rights_statement_instance
    @rights_statement_instance ||= Hyrax.config.rights_statement_service_class.new
  end

  # Blacklight facet field helper_method for rights statement controlled vocabulary
  # @param value [String] value that conforms to a rights statement CV ID
  # @return [String] license human-readable label
  def rights_statement_title_by_id(value)
    rights_statement_instance.label(value)
  end

  # A Blacklight index field helper_method
  # @param [Hash] options from blacklight helper_method invocation. Maps license URIs to links with labels.
  # @return [ActiveSupport::SafeBuffer] license links, html_safe
  def license_links(options)
    to_sentence(options[:value].map { |right| link_to license_service_instance.label(right), right })
  end

  # A Blacklight index field helper_method
  # @param [Hash] options from blacklight helper_method invocation. Maps rights statement URIs to links with labels.
  # @return [ActiveSupport::SafeBuffer] rights statement links, html_safe
  def rights_statement_links(options)
    to_sentence(options[:value].map { |right| link_to rights_statement_instance.label(right), right })
  end

  def title_by_id(id)
    (ActiveFedora::SolrService.query("id:#{id}", rows: 1, fl: ["title_tesim"])&.first || {})["title_tesim"]&.first
  end
end
