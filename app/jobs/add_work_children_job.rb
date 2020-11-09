class AddWorkChildrenJob < ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  # @param [String] parent_id ID string of parent work
  # @param [Array/String] child_ids Array of child work IDs or string of single child ID
  # @param [Boolean] delete_previous_children Whether already existing children should be deleted
  def perform(parent_id, child_ids, delete_previous_children=false)
    child_ids = Array(child_ids)
    parent = ::ActiveFedora::Base.find(parent_id)

    if delete_previous_children
      parent.members.each do |child|
        parent.ordered_members.delete(child)
        parent.members.delete(child)
      end
    end

    child_ids.each do |child_id|
      child = ::ActiveFedora::Base.find(child_id)
      parent.ordered_members << child unless parent.members.include?(child)
    end

    parent.save!
  end
end