module Morphosource::PhysicalObjectBehavior

  def organizations
    Organization.find(Array(organization_id))
  end

  def organization_titles
    organizations.map{ |o| o.title.first }
  end

  def media_solr
    return [] if id.nil?

    qry = "physical_object_id_ssim:#{self.id} AND has_model_ssim:Media"
    ActiveFedora::SolrService.query(qry, rows: 999999)
  end

  def media
    ms = media_solr
    return [] if ms.blank?
    ids = ms.map(&:id).select { |id| Media.exists?(id) }
    Media.find(ids)
  end

  def public_media
    media.select { |m| m.visibility == 'open' }
  end

  def related_media_ids
    media.map{ |o| o.id }
  end

  def public_media_ids
    public_media.map{ |o| o.id }
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
