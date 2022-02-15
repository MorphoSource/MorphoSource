module Morphosource
  class OrganizationNormalizationJob < Hyrax::ApplicationJob

    queue_as Hyrax.config.update_slow_queue_name

    def perform(media_id: nil, organization_id: nil, user_email: nil, update_publication_status: nil)
      return false if [media_id, organization_id, user_email, update_publication_status].any?(&:nil?)
      @media = Media.find(media_id)
      @organization = Organization.find(organization_id)
      @team = Collection.find(@organization.team_id.first)
      @user = User.find_by(email: user_email)
      @update_publication_status = update_publication_status
      update_download_reviewer
      update_media_publication_status
      update_data_manager
      update_permissions
      # this goes last because it saves the media and enques the InheritPermissionsJob
      add_media_to_team
    end

    def update_download_reviewer
      # only organization download reviewers will be reviewers (kind of irrelevant, since it's open download)
      if @media.open?
        @media.download_reviewer = @organization.download_reviewer
      # if a download reviewer has been designated, include them along with the organization download reviewers
      elsif @media.private?
        @media.download_reviewer = (@media.download_reviewer + @organization.download_reviewer).uniq
      # if media is restricted download, include the default reviewer (regardless of whether one has been explicitly desginated) along with the organization download reviewers
      else
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
      @media.owner = @user.ms_id
      @media.edit_users += [@user]
    end

    def update_permissions
      copy_organization_permissions
      update_attachment
    end

    def copy_organization_permissions
      @media.morphosource_use_agreement_type = @organization.morphosource_use_agreement_type
      @media.required_archival_of_published_derivatives = @organization.required_archival_of_published_derivatives
      @media.permits_commercial_use = @organization.permits_commercial_use
      @media.permits_3d_use = @organization.permits_3d_use
      @media.rights_holder = @organization.rights_holder
      @media.preview_mode = @organization.preview_mode
      @media.license = @organization.license
      @media.rights_statement = @organization.rights_statement
    end

    def update_attachment
      @media.agreement_uri = @organization.agreement_uri
      Morphosource::AttachmentService.delete(@media.id, 'agreement')
      if @organization.attachment('agreement')
        Morphosource::AttachmentService.create_copy(@media, 'agreement', @organization)
      end
    end

    def add_media_to_team
      @team.reindex_extent = ::Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
      @media.member_of_collections += [@team]
      Hyrax::PermissionTemplateApplicator.apply(@team.permission_template).to(model: @media)
      @media.save!
      InheritPermissionsJob.perform_later(@media)
    end
  end
end
