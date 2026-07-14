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

    # Returns ms_ids of the users who should approve download requests for this media:
    # download_reviewer if it resolves to any users, the owner otherwise
    def reviewer
      Morphosource::DownloadReviewerResolverService.resolve_for_media(self)
    end

    # Returns the Users or OrganizationCollections whose ms_ids or prefixed ids are stored in download_reviewer
    def download_reviewer_objects
      user_ids, org_ids = Morphosource::DownloadReviewerResolverService.partition_values(download_reviewer)
      User.where(ms_id: user_ids) + OrganizationCollection.where(id: org_ids)
    end

  end
end
