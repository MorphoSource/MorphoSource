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

  # Forces a Solr commit first so a media attached moments ago isn't missed.
  # @return [String, nil] error message if media is still attached, else nil
  def blocking_media_message
    ActiveFedora::SolrService.commit
    current_media = media
    return nil if current_media.blank?

    "Cannot delete this record while it still has associated media (#{current_media.map(&:id).join(', ')}), which may not be public. Detach or reassign the media first."
  end

  # organization_id_was is unreliable for this multi-valued property, so re-read the pre-change value from Fedora directly.
  def capture_original_organization_id
    @original_organization_id = new_record? ? [] : self.class.find(id).organization_id
  end

  # Creates pending organization transfers for this specimen's media when its organization changes.
  def check_for_media_organization_transfer
    new_org = resolve_organization_collection(organization_id)
    return unless new_org&.media_ownership_transfer?

    old_org = resolve_organization_collection(@original_organization_id)
    return unless old_org

    media.each do |m|
      next unless m.user_with_ownership == old_org.id
      TransferToOrganizationJob.perform_later(m.id, organization_id: new_org.id)
    end
  end

  private

  def prevent_destroy_with_media
    message = blocking_media_message
    return if message.nil?

    errors.add(:base, message)
    throw :abort
  end

  # Resolves the first id that's a live OrganizationCollection, skipping blank/legacy ids rather than raising.
  def resolve_organization_collection(ids)
    Array(ids).each do |oid|
      next if oid.blank? || !ActiveFedora::Base.exists?(oid)
      obj = ActiveFedora::Base.find(oid)
      return obj if obj.is_a?(OrganizationCollection)
    end
    nil
  end
end
