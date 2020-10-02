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

  def public_media
    media.select { |m| m.visibility == 'open' }
  end

  def media_types
    media.map{ |m| m.media_type[0] }
  end

  def public_media_types
    public_media.map{ |m| m.media_type.first }
  end

  def human_readable_media_types
    media.map{ |m| m.human_readable_media_type.first }
  end

  def public_human_readable_media_types
    public_media.map{ |m| m.human_readable_media_type.first }
  end

  def media_keyword
    media.each_with_object([]) do |m, keyword|
      m.keyword.each do |k|
        keyword << k
      end
    end
  end

  def public_media_keyword
    public_media.each_with_object([]) do |m, keyword|
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

  def media_member_of_public_collection_ids
    public_media.each_with_object([]) do |m, collections|
      m.member_of_public_collection_ids.each do |id|
        collections << id
      end
    end
  end
end
