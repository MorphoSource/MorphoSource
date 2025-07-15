class AddCollectionMembersJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.update_medium_queue_name

  # @param [String] collection_id ID string of collection
  # @param [Array/String] member_ids Array of work IDs or string of single work ID
  def perform(collection_id, member_ids)
    puts "PERFORMING AddCollectionMembersJob: collection_id=#{collection_id}, member_ids=#{member_ids}"
    if SequentialSectionList.exists?(collection_id)
      c = SequentialSectionList.find(collection_id)
    elsif MediaList.exists?(collection_id)
      c = MediaList.find(collection_id)
    elsif Collection.exists?(collection_id)
      c = Collection.find(collection_id)
    else
      return false
    end
    puts "!!!!!!!! Found collection: #{c.id} (#{c.class})"
    member_ids = Array(member_ids).select { |m_id| Media.exists?(m_id) }
    puts "!!!!!!! Filtered member_ids: #{member_ids.inspect}"
    return false if !member_ids.present?
    puts "!!!!!!! Adding members to collection #{c.id} (#{c.class})"
    if member_ids.count > 1
      member_ids.each do |member_id|
        AddCollectionMembersJob.perform_later(collection_id, member_id)
      end
    else
      puts "!!!!!!! Adding single member #{member_ids.first} to collection #{c.id} (#{c.class})"
      c.add_member_objects member_ids
    end
  end

end