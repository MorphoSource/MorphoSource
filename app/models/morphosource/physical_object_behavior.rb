module Morphosource::PhysicalObjectBehavior

  def organizations
    ActiveFedora::Base.find(Array(organization_id))
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

  def media_member_of_team_ids
    media_collection_ids_of_type("Team")
  end

  def media_member_of_project_ids
    media_collection_ids_of_type("Project")
  end

  def media_collection_ids_of_type(type)
    collection_ids = media.map(&:member_of_collection_ids).reject(&:blank?)
    return [] if collection_ids.empty?
    qry = "(id:(#{collection_ids.join(' OR ')}) AND human_readable_type_tesim:#{type})"
    collections = ActiveFedora::SolrService.query(qry, rows: 999999)
    collections.map(&:id)
  end


  def media_member_of_public_collection_ids
    public_media.each_with_object([]) do |m, collections|
      m.member_of_public_collection_ids.each do |id|
        collections << id
      end
    end
  end

  private

  # Blocks destroying this record while it still has associated media, regardless of
  # caller (UI, console, rake task, background job). This is Solr-based (via #media), so
  # it cannot catch a media whose real Fedora link was never indexed in Solr in the first
  # place -- same known limitation as Morphosource::MergeBiologicalSpecimenService. Forcing
  # a hard commit first narrows that window but does not eliminate it. No admin override --
  # media must be detached/reassigned before the record can be deleted.
  def prevent_destroy_with_media
    ActiveFedora::SolrService.commit
    return if media.blank?

    errors.add(:base, "Cannot delete this record while it still has associated media (#{media.map(&:id).join(', ')}). Detach or reassign the media first.")
    throw :abort
  end
end
