module Morphosource::PhysicalObjectBehavior

  def organizations
    member_of.select{ |work| work.class == Organization }
  end

  def organization_titles
    organizations.map{ |o| o.title.first }
  end

  def media
    descendants.select{ |d| d.class == Media }
  end

  def media_types
    media.map{ |m| m.media_type[0] }
  end

  def human_readable_media_types
    media_types.map do |type|
      if type == "CTImageSeries"
        "CT Image Series"
      elsif type == "PhotogrammetryImageSeries"
        "Photogrammetry Image Series"
      else
        type
      end
    end
  end

  def media_keyword
    media.each_with_object([]) do |m, keyword|
      m.keyword.each do |k|
        keyword << k
      end
    end
  end

  def media_collections
    media.each_with_object([]) do |m, collections|
      m.member_of_collections.each do |c|
        collections << c.title.first
      end
    end
  end
end
