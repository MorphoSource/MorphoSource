# frozen_string_literal: true

module Morphosource
  module Dashboard
    # Allows admins to link teams to organizations from the collection dashboard view and team managers to update an organization's default media permissions.
    class LinkedTeamsController < ApplicationController
      include LinkedTeamsBehavior

      before_action :find_team_and_organization

      def link_organization
        return unless current_user.admin?

        error_message = ""
        if team_has_view_access_to_another_organization?
          error_message += @view_access_message
        end
        if team_has_edit_access_to_another_organization?
          error_message += @edit_access_message
        end

        if error_message != ""
          flash[:error] = error_message
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
        redirect_to team_edit_path(@team), flash: { notice: flash[:notice] }
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
        flash[:notice] = "Permissions updated."
        redirect_back_organization
      end

      def team_has_view_access_to_another_organization?
        @view_access_message = ""
        docs = Morphosource::SolrService.new.get_docs("read_access_group_ssim:#{@team.id}_managers")
        if docs.count > 0
          media_ids = []
          po_ids = []
          rogue_orgs = []
          docs.each do |d|
            if d["has_model_ssim"] == ["Media"]
              media_ids << d["id"]
              rogue_orgs << d["media_organization_ssim"]
            elsif d["has_model_ssim"] == ["BiologicalSpecimen"] || d["has_model_ssim"] == ["CulturalHeritageObject"]
              po_ids << d["id"]
              rogue_orgs << d["organization_ssim"]
            end
          end
        end
        if (media_ids.present? || po_ids.present?)
          @view_access_message = "<p>This team has view access to #{rogue_orgs.uniq.join(', ')} media and/or physical objects.  If the team has recently been unlinked from that organization, check back later. Otherwise, check the following: </p>"
          if media_ids.present?
            @view_access_message += "<p>media " + media_ids.uniq.join(', ') + "</p>"
          end
          if po_ids.present?
            @view_access_message += "<p>physical objects " + po_ids.uniq.join(', ') + "</p>"
          end
          return true
        else
          return false
        end
      end

      def team_has_edit_access_to_another_organization?
        @edit_access_message = ""
        docs = Morphosource::SolrService.new.get_docs("edit_access_group_ssim:#{@team.id}_managers")
        if docs.count > 0
          media_ids = []
          po_ids = []
          rogue_orgs = []
          docs.each do |d|
            if d["has_model_ssim"] == ["Media"]
              media_ids << d["id"]
              rogue_orgs << d["media_organization_ssim"]
            elsif d["has_model_ssim"] == ["BiologicalSpecimen"] || d["has_model_ssim"] == ["CulturalHeritageObject"]
              po_ids << d["id"]
              rogue_orgs << d["organization_ssim"]
            end
          end
        end
        if (media_ids.present? || po_ids.present?)
          @edit_access_message = "<p>This team has edit access to #{rogue_orgs.uniq.join(', ')} media and/or physical objects.  If the team has recently been unlinked from that organization, check back later. Otherwise, check the following: </p>"
          if media_ids.present?
            @edit_access_message += "<p>media " + media_ids.uniq.join(', ') + "</p>"
          end
          if po_ids.present?
            @edit_access_message += "<p>physical objects " + po_ids.uniq.join(', ') + "</p>"
          end
          return true
        else
          return false
        end
      end

    end
  end
end
