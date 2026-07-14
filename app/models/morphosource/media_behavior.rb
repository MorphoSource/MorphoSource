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
    #   - If no configured target resolves, the media owner is used.
    def reviewer
      if download_reviewer.present?
        user_ids, org_ids = Morphosource::DownloadReviewerResolverService.partition_values(download_reviewer)
        user_reviewers = User.where(ms_id: user_ids).map(&:ms_id)
        organization_reviewers = OrganizationCollection.where(id: org_ids)
                                                        .flat_map(&:media_download_reviewers)
        resolved_reviewers = (user_reviewers + organization_reviewers).uniq
        return resolved_reviewers if resolved_reviewers.present?
      end

      if (organization = OrganizationCollection.find_by(id: Array(user_with_ownership)))
        organization.media_download_reviewers
      else
        Array(user_with_ownership)
      end
    end

    # Returns the Users or OrganizationCollections whose ms_ids or prefixed ids are stored in download_reviewer
    def download_reviewer_objects
      user_ids, org_ids = Morphosource::DownloadReviewerResolverService.partition_values(download_reviewer)
      User.where(ms_id: user_ids) + OrganizationCollection.where(id: org_ids)
    end

  end
end
