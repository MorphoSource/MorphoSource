class RemoveWorkChildrenJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.update_slow_queue_name

  # @param [String] parent_id ID string of parent work
  def perform(parent_id)
    if ::ActiveFedora::Base.exists?(parent_id)
      parent = ::ActiveFedora::Base.find(parent_id)
    else
      return false
    end

    parent.ordered_members = []
    parent.members = []
    parent.save!
  end
end