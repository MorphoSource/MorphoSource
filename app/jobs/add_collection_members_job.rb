class AddCollectionMembersJob < ApplicationJob
  queue_as Hyrax.config.update_slow_queue_name

  # @param [String] collection_id ID string of collection
  # @param [Array/String] member_ids Array of work IDs or string of single work ID
  def perform(collection_id, member_ids)
    if Collection.exists?(collection_id)
      c = Collection.find(collection_id)
      c.reindex_extent = ::Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
      collection_member_work_ids = c.member_work_ids
    else
      return false
    end

    member_ids = member_ids.
      select { |m_id| Media.exists?(m_id) && !collection_member_work_ids.include?(m_id) }
    return false if !member_ids.present?

    c.add_member_objects member_ids
  end
end