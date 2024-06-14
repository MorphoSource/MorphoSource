class AddCollectionMembersJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.update_medium_queue_name

  # @param [String] collection_id ID string of collection
  # @param [Array/String] member_ids Array of work IDs or string of single work ID
  def perform(collection_id, member_ids)
    if Collection.exists?(collection_id)
      c = Collection.find(collection_id)
      c.reindex_extent = ::Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
    else
      return false
    end

    member_ids = Array(member_ids).select { |m_id| Media.exists?(m_id) }
    return false if !member_ids.present?

    if member_ids.count > 1
      member_ids.each do |member_id|
        AddCollectionMembersJob.perform_later(collection_id, member_id)
      end
    else
      c.add_member_objects member_ids
      update_physical_object_index member_ids.first
    end
  end

  def update_physical_object_index(id)
    member = Media.find(id)
    object_id = member.physical_object_id
    ActiveFedora::Base.where(id: object_id).first.try(:update_index) if object_id.present?
  end

end