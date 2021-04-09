# frozen_string_literal: true

module Morphosource
  module Dashboard
    module LinkedTeamsBehavior

      private

      def add_organization
        @organization.team_id = [@team.id]
        @organization.save
        add_read_permissions
      end

      def add_read_permissions
        media = @organization.outside_media
        media.each do |m|
          m.read_groups += @groups
          m.save
          m.file_sets.each do |f|
            f.read_groups += @groups
            f.save
          end
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
          m.file_sets.each do |f|
            f.read_groups -= @groups
            f.save
          end
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
        create_attachment_if_needed
        format_update_params
        @params.permit!
        @organization.update(@params)
      end

      def create_attachment_if_needed
        # Handle possible attachment upload
        if @params[:agreement_uri].present? && Morphosource::AttachmentService.get(@organization.id, 'agreement').present?
          Morphosource::AttachmentService.delete(@organization.id, 'agreement')
        elsif params[:agreement] && Morphosource.attachment_formats.include?(File.extname(params[:agreement].original_filename))
          Morphosource::AttachmentService.create(@organization.id, 'agreement', params[:agreement])
          params.delete(:agreement)
          @params[:agreement_uri] = ''
        elsif params[:media_attachment_delete] == 'delete'
          Morphosource::AttachmentService.delete(@organization.id, 'agreement')
          params.delete(:media_attachment_delete)
        end
      end

      def format_update_params
        format_download_permission
        format_rights_holder
        multi_value_fields = [:download_permission, :download_reviewer, :cite_as, :permits_3d_use, :permits_commercial_use, :rights_statement, :agreement_uri, :morphosource_use_agreement_type, :required_archival_of_published_derivatives, :preview_mode]
        multi_value_fields.each do |field|
          @params[field] = Array(@params[field])
        end
      end

      def format_download_permission
        if @params[:visibility].present?
          @params[:download_permission] = @params[:visibility]
          @params.delete(:visibility)
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
