# frozen_string_literal: true

module Morphosource
  module Dashboard
    # Allows admins to link teams to organizations from the collection dashboard view and team managers to update an organization's default media permissions.
    class LinkedTeamsController < ApplicationController
      include LinkedTeamsBehavior

      before_action :find_team_and_organization

      def link_organization
        return unless current_user.admin?

        LinkOrganizationJob.perform_later(@team.id, @organization.id)

        flash[:notice] = 'Link organization job has been submitted for background processing. Return to team or organization page later.'
        redirect_back_organization
      end

      def unlink_organization
        return unless current_user.admin?

        ClearOrganizationJob.perform_later(@team.id)

        flash[:notice] = 'Clear organization job has been submitted for background processing. Return to team or organization page later.'
        redirect_back_organization
      end

      def update_permissions
        return unless current_user.can?(:edit, @team)

        update_organization
        redirect_back_organization
      end
    end
  end
end
