# frozen_string_literal: true

module Morphosource
  module Dashboard
    module LinkedTeamsBehavior

      private

      def add_organization
        @organization.team_id = [@team.id]
        @organization.save
        add_read_permissions
        add_permissions_for_po
      end

      def add_read_permissions
        media = @organization.outside_media
        media.each do |m|
          media_read_groups = m.read_groups + @groups
          UpdateWorkAccessGroupsJob.perform_later(m, media_read_groups)
          m.file_sets.each do |f|
            f_read_groups = f.read_groups + @groups
            UpdateWorkAccessGroupsJob.perform_later(f, f_read_groups)
          end
        end
      end

      def add_permissions_for_po        
        @po_edit_groups = groups_for_po(@team.id)
        @organization.physical_objects.each do |po|
          final_read_groups = po.read_groups + @po_edit_groups
          final_edit_groups = po.edit_groups + @po_edit_groups
          UpdateWorkAccessGroupsJob.perform_later(po, final_read_groups, final_edit_groups) 
        end
      end

      def clear_organization
        return unless @team.organization

        @old_org = @team.organization
        remove_read_permissions
        remove_permissions_for_po
        @old_org.team_id = []
        @old_org.save
      end

      def remove_read_permissions
        media = @old_org.outside_media
        media.each do |m|
          media_read_groups = m.read_groups - @groups
          UpdateWorkAccessGroupsJob.perform_later(m, media_read_groups)
          m.file_sets.each do |f|
            f_read_groups = f.read_groups - @groups
            UpdateWorkAccessGroupsJob.perform_later(f, f_read_groups)
          end
        end
      end

      def remove_permissions_for_po
        @po_edit_groups = groups_for_po(@team.id)
        physical_objects = @old_org.physical_objects
        physical_objects.each do |po|
          final_read_groups = po.read_groups - @po_edit_groups
          final_edit_groups = po.edit_groups - @po_edit_groups
          UpdateWorkAccessGroupsJob.perform_later(po, final_read_groups, final_edit_groups)
        end
      end

      def find_team_and_organization
        @team = Collection.find(params[:id])
        @organization = find_organization
        @groups = @team.user_groups.map(&:name)
        @po_edit_groups = groups_for_po(@team.id)
      end

      def groups_for_po(team_id)
        roles = Collection::EDIT_GROUP_ROLES
        groups = []
        roles.each do |role|
          groups.push(team_id + '_' + role)
        end
        return groups
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
        ensure_blank_values
        create_attachment_if_needed
        format_update_params
        correct_empty_str_arrays
        check_proxy_deposit_requests
byebug
        @params.permit!
        @organization.update(@params)
      end

      def check_proxy_deposit_requests
        return unless @params["data_manager"].present?
        return if @params["data_manager"].first == @organization.data_manager.first
        old_manager = User.find_by_user_key(@organization.data_manager.first)
        if (requests_to_handle = ProxyDepositRequest.where(organization_transfer: true, receiving_user_id: old_manager.id, status: 'pending')).present?
byebug
          requests_to_handle.each do |r|
            puts "updating..."
          end
        end
      end

      def ensure_blank_values
        blank_fields.each do |blank_field|
          if ActiveModel::Type::Boolean.new.cast(@params[blank_field])
            @params[blank_field.sub('_blank', '')] = ['']
          end
        end
      end

      def blank_fields
        ['license_blank', 'rights_holder_blank', 'rights_statement_blank']
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
        multi_value_fields = [:data_manager, :download_permission, :download_reviewer, :permits_3d_use, 
          :permits_commercial_use, :license, :rights_statement, :agreement_uri, 
          :morphosource_use_agreement_type, :required_archival_of_published_derivatives, 
          :preview_mode, :rights_holder, :rights_holder_blank, :rights_statement_blank, 
          :license_blank, :permissions_enforcement_mode]
        multi_value_fields.each do |field|
          @params[field] = Array(@params[field]) if @params.key?(field)
        end
      end

      def format_download_permission
        if @params[:visibility].present?
          @params[:download_permission] = @params[:visibility]
          @params.delete(:visibility)
        end
      end

      def correct_empty_str_arrays
        @params.transform_values! { |v| v == [''] ? [] : v }
      end

      def redirect_back_organization
        redirect_back(fallback_location: hyrax.edit_dashboard_collection_path(params[:id], locale: 'en', anchor: 'organization'))
      end
    end
  end
end
