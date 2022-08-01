class UpdateOrgLinkedTeamMediaAccessJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.update_slow_queue_name

  def perform(work, team_id)
    get_groups(team_id)
    add_read_access(work)
  end

  private

  def get_groups(team_id)
    roles = Collection::DEFAULT_GROUP_ROLES
    @groups = []
	  roles.each do |role|
	    @groups.push(team_id + '_' + role)
	  end
  end

  def add_read_access(work)
    work_changed = false
    unless (@groups - work.read_groups).empty?
      work.read_groups += @groups
      work_changed = true
    end
    if work_changed 
      puts "adding groups: #{@groups} to media #{work.id}"
      work.save
    end
  end

end
