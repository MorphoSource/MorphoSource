class UpdateWorkAccessGroupsJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.update_fast_queue_name

  def perform(work, read_groups=nil, edit_groups=nil)
    work.read_groups = read_groups unless read_groups.nil?
    work.edit_groups = edit_groups unless edit_groups.nil?
    work.save!
  end
end