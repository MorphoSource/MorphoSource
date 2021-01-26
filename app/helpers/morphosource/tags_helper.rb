module Morphosource::TagsHelper

  def physical_object(document)
    @object = Morphosource::PhysicalObjectParentSearchService.call({ id: document.id })&.first
    return '' if @object.nil?
    if @object.specimen?
      @taxonomy = Morphosource::TaxonomySearchService.call({ 'id' => @object.taxonomy_id&.first})&.first if @object.taxonomy_id.present?
      if @taxonomy
        ("<td>${link_to(@physical_object.title.first, hyrax_biological_specimen_path(@physical_object.id))}</td>\n
        <td>${link_to(taxonomy.title.first, hyrax_taxonomy_path(taxonomy.id))}</td>").html_safe
      else
        ("<td>${link_to(@physical_object.title.first, hyrax_biological_specimen_path(@physical_object.id))}</td>\n
        <td></td>").html_safe
      end
    else
      link_to(@object.title.first, hyrax_cultural_heritage_object_path(@object.id))
    end
  end

  def get_media_info(document)
    @object = Morphosource::PhysicalObjectParentSearchService.call({ id: document.id })&.first
    if @object
      @taxonomy = Morphosource::TaxonomySearchService.call({ 'id' => @object.taxonomy_id&.first})&.first if @object.taxonomy_id.present?
    else
      @taxonomy = nil
    end
    @type = document[:media_type_tesim]&.first
    @publication_status = Media.find(document.id).publication_status
  end

  def tag_links(document)
    safe_join(document.keyword.map { |tag| link_to(tag, main_app.tag_path(tag)) }, ", ".html_safe)
  end

  def taxonomy(document)
    @physical_object.taxonomy
  end

end
