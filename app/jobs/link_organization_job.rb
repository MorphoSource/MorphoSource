class LinkOrganizationJob < ApplicationJob
  include Morphosource::Dashboard::LinkedTeamsBehavior

  queue_as Hyrax.config.reindex_queue_name

  def perform(team_id, organization_id)
    @team = Collection.find(team_id)
    @organization = Organization.find(organization_id)
    @groups = @team.user_groups.map(&:name)

    clear_organization
    add_organization
  end
end