# All methods should work for both media works and media solr docs.
module Morphosource
  module MediaBehavior

    def publication_status
      case fileset_accessibility&.first
      when 'open'
        'open'
      when 'restricted_download'
        'restricted'
      when 'private'
        'private'
      else
        'private'
      end
    end

    def can_add_to_cart?
      public?
    end

    def open_download?
      fileset_accessibility == ['open']
    end

    def open?
      publication_status == "open"
    end

    def restricted?
      fileset_accessibility == ['restricted_download']
    end
    alias restricted_download? restricted?

    def private?
      visibility == "restricted"
    end

    # Returns ms_ids of the users who should approve download requests for this media.
    #
    # Resolves the reviewer target in order:
    #   1. media.download_reviewer, if present
    #   2. media.user_with_ownership, otherwise
    #
    # The target is then expanded:
    #   - An individual user target returns that user's ms_id.
    #   - An organization target returns the organization's download_reviewers,
    #     or its managers if no download_reviewers are configured.
    def reviewer
      if download_reviewer.present?
        user_reviewers = User.where(ms_id: Array(download_reviewer)).pluck(:ms_id)
        organization = OrganizationCollection.where(id: Array(download_reviewer)).first
        organization_reviewers = organization.present? ? organization.media_download_reviewers : []
        user_reviewers + organization_reviewers
      elsif (organization = OrganizationCollection.find_by(id: user_with_ownership))
        organization.media_download_reviewers
      else
        Array(user_with_ownership)
      end
    end
  end
end