class AddWorkChildrenJob < ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  # @param [String] parent_id ID string of parent work
  # @param [Array/String] child_ids Array of child work IDs or string of single child ID
  def perform(parent_id, child_ids, delete_existing=false)
    if ::ActiveFedora::Base.exists?(parent_id)
      parent = ::ActiveFedora::Base.find(parent_id)
    else
      return false
    end

    children = Array(child_ids)
      .select { |c| !parent.member_ids.include?(c) }
      .map { |c| ::ActiveFedora::Base.exists?(c) ? ::ActiveFedora::Base.find(c) : nil }
      .compact
    return false if !children.present?
    
    if delete_existing
      parent.members.each do |child|
        parent.ordered_members.delete(child)
        parent.members.delete(child)
        parent.save!
      end
    end

    parent.reload
    parent.ordered_members = (parent.ordered_members.to_a + children).uniq
    parent.save!
  end
end