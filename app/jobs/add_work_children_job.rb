class AddWorkChildrenJob < ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  # @param [String] parent_id ID string of parent work
  # @param [Array/String] child_ids Array of child work IDs or string of single child ID
  def perform(parent_id, child_ids)
    if ::ActiveFedora::Base.exists?(parent_id)
      parent = ::ActiveFedora::Base.find(parent_id)
    else
      return false
    end

    children = Array(child_ids)
      .map { |c| ::ActiveFedora::Base.exists?(c) ? ::ActiveFedora::Base.find(c) : nil }
      .compact
    return false if !children.present?
    
    parent.members.each do |child|
      parent.ordered_members.delete(child)
      parent.members.delete(child)
      parent.save!
    end

    parent.ordered_members = children
    parent.save!
  end
end