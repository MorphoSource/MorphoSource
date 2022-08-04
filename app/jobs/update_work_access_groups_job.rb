class UpdateWorkAccessGroupsJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.update_fast_queue_name

  def perform(work, read_groups=nil, edit_groups=nil)
    work.read_groups = read_groups if read_groups.present?
    work.edit_groups = edit_groups if edit_groups.present?
    work.save!
  end
end