module Morphosource
  class OrganizationNormalizationJob < Hyrax::ApplicationJob

    queue_as Hyrax.config.update_medium_queue_name

    def perform(media_id: nil, organization_id: nil, user_email: nil, remove_previous_reviewers: false, update_publication_status: nil)
      return false if [media_id, organization_id, user_email, remove_previous_reviewers, update_publication_status].any?(&:blank?)
      @organization = select_organization(organization_id)
      if @organization.is_a? Organization
        normalize_team_media(media_id, user_email, remove_previous_reviewers, update_publication_status)
      elsif @organization.is_a? OrganizationCollection
        normalize_organization_media(media_id, user_email, remove_previous_reviewers, update_publication_status)
      end
    end

    # refactor to remove this method when organizations have been migrated to collections
    def normalize_team_media(media_id, user_email, remove_previous_reviewers, update_publication_status)
      @media = Media.find(media_id)
      @team = Collection.find_by(id: @organization&.team_id&.first)
      @user = User.find_by(email: user_email)
      @remove_previous_reviewers = remove_previous_reviewers
      @update_publication_status = update_publication_status
      update_download_reviewer
      update_media_publication_status
      update_data_manager
      update_permissions
      add_media_to_team if @team.present?
      save_and_reindex
    end

    def normalize_organization_media(media_id, user_email, remove_previous_reviewers, update_publication_status)
      @media = Media.find(media_id)
      @team = Collection.find_by(id: @organization&.team_id&.first)
      @user = User.find_by(email: user_email)
      @remove_previous_reviewers = remove_previous_reviewers
      @update_publication_status = update_publication_status
      update_download_reviewer
      update_media_publication_status
      update_data_manager
      update_permissions
      save_and_reindex
    end

    def update_download_reviewer
      if @media.open? || @remove_previous_reviewers == "true"
        @media.download_reviewer = @organization.download_reviewer
      elsif @media.private?
        # if a download reviewer has been designated, include them along with the organization download reviewers
        @media.download_reviewer = (@media.download_reviewer + @organization.download_reviewer).uniq
      else
        # if media is restricted download, include the default reviewer (regardless of whether one has been explicitly desginated) along with the organization download reviewers
        @media.download_reviewer = (@media.reviewer + @organization.download_reviewer.to_a).uniq
      end
    end

    def update_media_publication_status
      default = @organization.download_permission.first
      return if default.blank?

      case @update_publication_status
      when 'none'
        return

      when 'all'
        case default
        when 'restricted_download'
          @media.visibility = 'open'
          @media.fileset_accessibility = ['restricted_download']
        when 'open'
          @media.visibility = 'open'
          @media.fileset_accessibility = ['open']
        when 'restricted'
          @media.visibility = 'restricted'
          @media.fileset_accessibility = ['private']
        end
      when 'published'
        return if @media.private?

        case default
        when 'restricted_download'
          @media.visibility = 'open'
          @media.fileset_accessibility = ['restricted_download']
        when 'open'
          @media.visibility = 'open'
          @media.fileset_accessibility = ['open']
        when 'restricted'
          @media.visibility = 'restricted'
          @media.fileset_accessibility = ['private']
        end
      end
    end

    def update_data_manager
      if @organization.organization_collection?
        @media.owner = @organization.id
      else
        @media.owner = @user.ms_id
        @media.edit_users += [@user]
      end
    end

    def update_permissions
      copy_organization_permissions
      update_attachment
    end

    def copy_organization_permissions
      # copy organization settings to media if filled out or intentionally blank
      if @organization.rights_holder.present? || @organization.rights_holder_blank == ["1"]
        @media.rights_holder = @organization.rights_holder
      end
      if @organization.rights_statement.present? || @organization.rights_statement_blank == ["1"]
        @media.rights_statement = @organization.rights_statement
      end
      if @organization.license.present? || @organization.license_blank == ["1"]
        @media.license = @organization.license
      end
      # copy organization settings to media, unless org settings are blank ('no preference')
      @media.morphosource_use_agreement_type = @organization.morphosource_use_agreement_type unless @organization.morphosource_use_agreement_type.blank?
      @media.required_archival_of_published_derivatives = @organization.required_archival_of_published_derivatives unless @organization.required_archival_of_published_derivatives.blank?
      @media.permits_commercial_use = @organization.permits_commercial_use unless @organization.permits_commercial_use.blank?
      @media.permits_3d_use = @organization.permits_3d_use unless @organization.permits_3d_use.blank?
      @media.preview_mode = @organization.preview_mode unless @organization.preview_mode.blank?
    end

    def update_attachment
      return if (@organization.agreement_uri.blank? && @organization.attachment('agreement').blank?)

      @media.agreement_uri = @organization.agreement_uri
      Morphosource::AttachmentService.delete(@media.id, 'agreement')
      if @organization.attachment('agreement')
        Morphosource::AttachmentService.create_copy(@media, 'agreement', @organization)
      end
    end

    # refactor to remove this method when organizations have been migrated to collections
    def add_media_to_team
      @team.reindex_extent = ::Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
      @media.member_of_collections += [@team]
      Hyrax::PermissionTemplateApplicator.apply(@team.permission_template).to(model: @media)
    end

    # refactor to remove this method when organizations have been migrated to collections
    def select_organization(organization_id)
      Organization.find_by(id: organization_id) || OrganizationCollection.find_by(id: organization_id)
    end

    def save_and_reindex
      @media.save!
      InheritPermissionsJob.perform_later(@media.id)
    end
  end
end
