# frozen_string_literal: true

module Morphosource
  module Dashboard
    # Allows admins to link teams to organizations from the collection dashboard view and team managers to update an organization's default media permissions.
    class LinkedTeamsController < ApplicationController
      before_action :find_team_and_organization

      def link_organization
        return unless current_user.admin?

        clear_organization
        add_organization
        redirect_back_organization
      end

      def update_permissions
        return unless current_user.can?(:edit, @team)

        update_organization
        redirect_back_organization
      end

      private

        def add_organization
          @organization.team_id = [params[:id]]
          @organization.save
          add_read_permissions
        end

        def add_read_permissions
          media = @organization.outside_media
          media.each do |m|
            m.read_groups += @groups
            m.save
          end
        end

        def clear_organization
          return unless @team.organization

          @old_org = @team.organization
          remove_read_permissions
          @old_org.team_id = []
          @old_org.save
        end

        def remove_read_permissions
          media = @old_org.outside_media
          media.each do |m|
            m.read_groups -= @groups
            m.save
          end
        end

        def find_team_and_organization
          @team = Collection.find(params[:id])
          @organization = find_organization
          @groups = @team.user_groups.map(&:name)
        end

        def find_organization
          case action_name
          when 'update_permissions'
            @team.organization
          when 'link_organization'
            Organization.find(params[:collection][:organization_id])
          end
        end

        def update_organization
          @params = params[:organization]
          format_update_params
          @params.permit!
          @organization.update(@params)
        end

        def format_update_params
          format_rights_holder
          multi_value_fields = [:download_permission, :download_reviewer, :cite_as, :permits_3d_use, :permits_commercial_use, :rights_statement, :terms_of_use]
          multi_value_fields.each do |field|
            @params[field] = Array(@params[field])
          end
        end

        def format_rights_holder
          @names = format_names
          @types = format_types
          combine_names_and_types
        end

        def format_names
          @params[:rights_holder_name].map{ |name| 'Name: ' + name + ', ' }
        end

        def format_types
          @params[:rights_holder_type].map{ |type| 'Type: ' + type }
        end

        def combine_names_and_types
          @params[:rights_holder] = @names.map {|name| name.concat(@types[@names.index(name)]) }
          delete_names_and_types
        end

        def delete_names_and_types
          @params.delete(:rights_holder_name)
          @params.delete(:rights_holder_type)
        end

        def redirect_back_organization
          redirect_back(fallback_location: hyrax.edit_dashboard_collection_path(params[:id], locale: 'en', anchor: 'organization'))
        end
    end
  end
end
