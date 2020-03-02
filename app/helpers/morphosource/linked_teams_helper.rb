# frozen_string_literal: true

module Morphosource
  # Helper for linking teams to organizations
  module LinkedTeamsHelper
    def unlinked_organizations
      orgs = Organization.all.select { |o| o.team_id.blank? }
      orgs.collect { |o| [o.title.first, o.id] }
    end
  end
end
