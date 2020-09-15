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


  def media_types
    media_types_service = Morphosource::MediaTypesService.new
    media_types_service.select_all_options.map do |label, value|
      value
    end
  end


  def total_media

    total_bso_media + total_cho_media
  end

end
