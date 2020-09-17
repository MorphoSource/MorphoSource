module Hyrax::Browse::BrowseHelper

  def browse_service
    @browse_service ||= Morphosource::BrowseService.new
  end

  def bso_ids
    @bso_ids ||= browse_service.bso_ids
  end

  def cho_ids
    @cho_ids ||= browse_service.cho_ids
  end

  def total_bso
    bso_ids.length
  end

  def total_cho
    cho_ids.length
  end

  def total_po
    total_bso + total_cho
  end

  def total_bso_media
    @total_bso_media ||= browse_service.total_media_by_po_ids(bso_ids)
  end

  def total_cho_media
    @total_cho_media ||= browse_service.total_media_by_po_ids(cho_ids)
  end

  def total_media_by_po
    total_bso_media + total_cho_media
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

  def map_media_type(t)
    case t
      when 'CTImageSeries' then 'ctimagesery'
      when 'PhotogrammetryImageSeries' then 'photogrammetryimagesery'
      else t.downcase
    end
  end

  def get_media_type_info
    @media_facets, @total_media = browse_service.media_facets
    @media_type_facets = @media_facets["media_type_tesim"]
    @modality_facets = @media_facets["media_modality_sim"]
  end  

  def total_media
    @total_media
  end

  def media_count_by_media_type(type)
    count = @media_type_facets[map_media_type(type)]
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
