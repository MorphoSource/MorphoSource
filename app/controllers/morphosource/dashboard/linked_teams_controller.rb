# frozen_string_literal: true

module Morphosource
  module Dashboard
    # Allows admins to link teams to organizations from the collection dashboard view and team managers to update an organization's default media permissions.
    class LinkedTeamsController < ApplicationController
      include LinkedTeamsBehavior

      before_action :find_team_and_organization

      def link_organization
        return unless current_user.admin?

        if team_has_view_access_to_another_organization?
          flash[:error] = "This team has view access to #{@rogue_orgs} media and/or physical objects. If the team has recently been unlinked from that organization, check back later. Otherwise, check the following media and/or physical objects: #{@rogue_ids}."
        else
          LinkOrganizationJob.perform_later(@team.id, @organization.id)
          flash[:notice] = 'Link organization job has been submitted for background processing. Return to team page later.'
        end
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

        if (
          params[:organization][:data_manager].present? && 
          (u = User.find_by_user_key(params[:organization][:data_manager])) &&
          !u.contributor?
        )
          flash[:error] = "Data manager selected for organization is not a contributor."
          redirect_back_organization and return
        end

        update_organization
        redirect_back_organization
      end

      def team_has_view_access_to_another_organization?
        # todo: might need to check for edit access, and possibly separate media and PO
        docs = Morphosource::SolrService.new.get_docs("read_access_group_ssim:#{@team.id}_managers")
        if docs.count > 0
          @rogue_ids = docs.map{|d| d["id"]}.join(', ')
          @rogue_orgs = docs.map{|d| d["media_organization_ssim"]}.uniq.join(', ')
          return true
        end
        false
      end
    end
  end
end
