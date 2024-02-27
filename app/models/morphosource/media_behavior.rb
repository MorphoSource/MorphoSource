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

    def reviewer
      download_reviewers = User.where(ms_id: download_reviewer.to_a).map(&:ms_id)
      download_reviewers.present? ? Array(download_reviewers) : Array(user_with_ownership)
    end

    def user_with_ownership
      OrganizationCollection.find_by(id: owner)&.id || User.find_by(ms_id: owner)&.ms_id || depositor
    end
  end
end