module Hyrax::Browse::BrowseHelper

  def browse_service
    @browse_service ||= Morphosource::BrowseService.new
  end

  # ---  methods for physical object types ---

  def get_media_po_type_info
    facets, @total_media = browse_service.media_po_type_facets
    po_type_facets = facets["media_physical_object_type_ssim"]
    @total_bso_media = po_type_facets["Biological Specimen"] || 0
    @total_cho_media = po_type_facets["Cultural Heritage Object"] || 0
  end

  def total_bso_media
    @total_bso_media
  end

  def total_cho_media
    @total_cho_media
  end

  def total_media_by_po
    total_bso_media + total_cho_media
  end

  def total_bso
    @total_bso ||= browse_service.total_bso
  end

  def total_cho
    @total_cho ||= browse_service.total_cho
  end

  def total_po
    total_bso + total_cho
  end

  # ---  methods for media types and modality ---

  def media_types
    media_types_service = Morphosource::MediaTypesService.new
    media_types_service.select_all_options.map do |label, value|
      value
    end
  end

  def modalities
    modalities_service = Morphosource::ModalitiesService.new
    modalities_service.select_all_options.map do |label, value|
      label
    end
  end

  def get_media_type_and_modality_info
    facets, @total_media = browse_service.media_type_and_modality_facets
    @media_type_facets = facets[Solrizer.solr_name('media_type', :facetable)]
    @modality_facets = facets['modality_ssim']
  end

  def total_media
    @total_media
  end

  def media_count_by_media_type(type)
    count = @media_type_facets[type]
    if count.present?
      return count.to_int
    else
      return 0
    end
  end

  def media_count_by_modality(modality)
    count = @modality_facets[modality]
    if count.present?
      return count.to_int
    else
      return 0
    end
  end

end
