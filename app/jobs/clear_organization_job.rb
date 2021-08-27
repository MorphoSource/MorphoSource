class ClearOrganizationJob < Hyrax::ApplicationJob
  include Morphosource::Dashboard::LinkedTeamsBehavior

  queue_as Hyrax.config.update_fast_queue_name

  def perform(team_id)
    @team = Collection.find(team_id)
    @groups = @team.user_groups.map(&:name)

    clear_organization
  end
end