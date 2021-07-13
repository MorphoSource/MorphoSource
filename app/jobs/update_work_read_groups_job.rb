class UpdateWorkReadGroupsJob < ApplicationJob
  queue_as Hyrax.config.update_fast_queue_name

  def perform(work, read_groups)
    work.read_groups = read_groups
    work.save!
  end
end