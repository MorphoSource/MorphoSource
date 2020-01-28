# frozen_string_literal: true

module Morphosource
  module Dashboard
    # Allows admins to link teams to organizations from the collection dashboard view
    class LinkedTeamsController < ApplicationController
      before_action :find_team_and_organization

      def link_organization
        return unless current_user.admin?

        clear_organization
        add_organization
        redirect_back(fallback_location: hyrax.edit_dashboard_collection_path(params[:id], locale: 'en', anchor: 'organization'))
      end

      private

        def add_organization
          @organization.team_id = [params[:id]]
          @organization.save
        end

        def clear_organization
          return unless @team.organization
          @old_org = @team.organization
          @old_org.team_id = []
          @old_org.save
        end

        def find_team_and_organization
          @organization = Organization.find(params[:collection][:organization_id])
          @team = Collection.find(params[:id])
        end
    end
  end
end
