class RemoveCollectionMembersJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.update_medium_queue_name

  # @param [String] collection_id ID string of collection
  # @param [Array/String] member_ids Array of work IDs or string of single work ID
  def perform(collection_id, member_ids)
    # Note: Collection.find_by(id: collection_id) or Collection.exists? for MediaList or SequentialSectionList sometimes returns nil even when the record exists.
    if SequentialSectionList.exists?(collection_id)
      c = SequentialSectionList.find(collection_id)
    elsif MediaList.exists?(collection_id)
      c = MediaList.find(collection_id)
    elsif Collection.exists?(collection_id)
      c = Collection.find(collection_id)
    else
      return false
    end

    member_ids = Array(member_ids).select { |m_id| Media.exists?(m_id) }
    return false if !member_ids.present?

    if member_ids.count > 1
      member_ids.each do |member_id|
        RemoveCollectionMembersJob.perform_later(collection_id, member_id)
      end
    else
      c.remove_member_objects member_ids
    end
  end

end