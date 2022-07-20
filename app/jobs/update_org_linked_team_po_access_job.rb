class UpdateOrgLinkedTeamPoAccessJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.update_slow_queue_name

  def perform(work, team_id)
    get_groups_for_po(team_id)
    add_edit_access_for_po(work)
		work.read_groups += @po_edit_groups
		work.edit_groups += @po_edit_groups
		add_edit_access_for_po(work)
  end

  private

  def get_groups_for_po(team_id)
    roles = Collection::EDIT_GROUP_ROLES
    @po_edit_groups = []
	  roles.each do |role|
	    @po_edit_groups.push(team_id + '_' + role)
	  end
  end

  def add_edit_access_for_po(work)
    work.read_groups += @po_edit_groups
    work.edit_groups += @po_edit_groups
    puts "adding read_groups and edit_groups: #{@po_edit_groups} to physical object #{work.id}"
    work.save
  end

end
