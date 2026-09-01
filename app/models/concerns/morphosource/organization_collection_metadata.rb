module Morphosource
  # Module to define core (non-modality specific) metadata properties for
  # Organization Collection
  module OrganizationCollectionMetadata
    extend ActiveSupport::Concern

    included do
      # media ownership transfer
      property :media_ownership_transfer, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/mediaOwnershipTransfer"), multiple: false

      # may a media name this organization as its download reviewer
      property :reviews_object_media_downloads, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/reviewsObjectMediaDownloads"), multiple: false

      # true: managers review; false: custom_download_reviewer_users do
      property :managers_are_download_reviewers, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/managersAreDownloadReviewers"), multiple: false

      # User ms_ids
      property :custom_download_reviewer_users, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/customDownloadReviewerUsers"), multiple: true

      property :ark, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/ark") do |index|
        index.as :stored_searchable
      end

      property :legacy_organization_work_id, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/legacyOrganizationWorkID"), multiple: false do |index|
        index.as :stored_searchable
      end
    end
  end
end
