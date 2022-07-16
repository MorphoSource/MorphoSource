# frozen_string_literal: true

module Morphosource
  module LinkedTeams
    module LinkedTeamsManagement
      include Morphosource::WorksControllerBehavior

      # called from imaging event and processing event controllers
      def update_media_team_access
        if @curation_concern.physical_object?        
          return if organization_id_param.nil?
        else
          return if parents_attributes.nil?
        end
        
        return if organizations_unchanged?

        update_linked_team_access
      end

      # this is also called from media actor
      def add_organization_team_access(works)
        works = Array(works)
        team_ids = linked_team_ids(new_orgs)
        return if team_ids.blank?
        get_groups(team_ids)
        works.each { |w| add_read_access(w) }
      end

      def add_organization_team_access_for_po
        team_ids = linked_team_ids(new_orgs)
        return if team_ids.blank?
        get_groups_for_po(team_ids)
        add_edit_access_for_po(@curation_concern)
      end

      # called from submissions controller
      def new_processing_event_updates(media)
        get_processing_event_values(media)
        add_organization_team_access(@media)
      end

      def get_processing_event_values(media)
        @curation_concern = media
        new_specimens = media.objects
        @new_orgs = specimen_organizations(new_specimens)
        find_all_media
      end

      def record_original_organizations
        @original_organizations = Organization.find(Array(@curation_concern.organization_id))
      end

      def record_original_objects
        @original_objects = ActiveFedora::Base.find(Array(@curation_concern.physical_object_id))
      end

      def record_original_parents
        @original_parents = @curation_concern.member_of
      end

      private

      def parents_attributes
        params[work_type][:work_parents_attributes]
      end

      def work_type
        @curation_concern.model_name.param_key
      end

      def organization_id_param
        params[work_type].present? ? params[work_type][:organization_id] : nil
      end

      def organizations_unchanged?
        old_orgs.sort == new_orgs.sort
      end

      def old_orgs
        @old_orgs ||= specimen_organizations(old_specimens)
      end

      def new_orgs
        @new_orgs ||= specimen_organizations(new_specimens)
      end

      def specimen_organizations(specimens)
        specimens.each_with_object([]) do |s, orgs|
          s.organization_id.each do |organization_id|
            orgs << Organization.find(organization_id) if Organization.exists?(organization_id)
          end
        end
      end

      def update_linked_team_access
        find_all_media
        unless old_orgs.blank?
          remove_organization_team_access
          remove_organization_team_access_for_po
        end
        add_organization_team_access(@media)
        if @curation_concern.physical_object?        
          add_organization_team_access_for_po
        end
      end

      def find_all_media
        if @curation_concern.class == BiologicalSpecimen || @curation_concern.class == CulturalHeritageObject
          works = @curation_concern.media
        else
          works = @curation_concern.descendants << @curation_concern
        end
        @media = select_media(works)
      end

      def remove_organization_team_access
        team_ids = linked_team_ids(old_orgs)
        return if team_ids.blank?

        get_groups(team_ids)
        @media.each { |m| remove_read_access(m) }
      end

      def remove_organization_team_access_for_po
        team_ids = linked_team_ids(old_orgs)
        return if team_ids.blank?

        get_groups_for_po(team_ids)
        remove_edit_access_for_po(@curation_concern)
      end

      def linked_team_ids(organizations)
        organizations.map { |o| o.team_id.first }.compact
      end

      def get_groups(team_ids)
        roles = Collection::DEFAULT_GROUP_ROLES
        @groups = []
        team_ids.each do |id|
          roles.each do |role|
            @groups.push(id + '_' + role)
          end
        end
      end

      def get_groups_for_po(team_ids)
        roles = Collection::EDIT_GROUP_ROLES
        @po_edit_groups = []
        team_ids.each do |id|
          roles.each do |role|
            @po_edit_groups.push(id + '_' + role)
          end
        end
      end

      def remove_read_access(work)
        work.read_groups -= @groups
        work.save
      end

      def remove_edit_access_for_po(work)
        work.read_groups -= @po_edit_groups
        work.edit_groups -= @po_edit_groups
        work.save
      end

      def add_read_access(work)
        work.read_groups += @groups
        work.save
      end

      def add_edit_access_for_po(work)
        work.read_groups += @po_edit_groups
        work.edit_groups += @po_edit_groups
        work.save
      end
    end
  end
end
