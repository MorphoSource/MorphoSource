# frozen_string_literal: true

module Morphosource
  # Expands Media#download_reviewers tokens into the ms_ids of the Users who review the media's
  # Download Requests. Organizations are memoized per instance, so use one instance per
  # operation (a make_request call, a job batch, a page), not one per media.
  #
  # @example
  #   resolver = Morphosource::DownloadReviewerResolver.new
  #   media_docs.map { |doc| resolver.call(doc) }
  class DownloadReviewerResolver
    TOKEN_PREFIX = Morphosource::MediaMetadata::ORG_COLLECTION_TOKEN_PREFIX

    def initialize
      @organization_reviewers = {}
    end

    # @param media [Media, SolrDocument] anything answering #download_reviewers
    # @return [Array<String>] reviewer ms_ids; never empty, falling back to the batch User
    def call(media)
      tokens, ms_ids = Array(media.download_reviewers).reject(&:blank?).uniq
                                                      .partition { |identity| identity.start_with?(TOKEN_PREFIX) }

      reviewers = existing_users(ms_ids) +
                  tokens.flat_map { |token| organization_reviewers(token.delete_prefix(TOKEN_PREFIX)) }

      # Fall back once on the whole union, never per token.
      reviewers.uniq.presence || [batch_user_ms_id]
    end

    private

    def existing_users(ms_ids)
      return [] if ms_ids.empty?

      User.where(ms_id: ms_ids).pluck(:ms_id)
    end

    def organization_reviewers(organization_id)
      @organization_reviewers[organization_id] ||= load_organization_reviewers(organization_id)
    end

    # Solr, not Fedora: lifecycle jobs call this in large batches. A deleted organization
    # resolves to nothing rather than raising, so it cannot block a batch.
    def load_organization_reviewers(organization_id)
      document = ActiveFedora::SolrService.query("id:#{organization_id}",
                                                 fq: ['has_model_ssim:OrganizationCollection'],
                                                 rows: 1).first
      return [] if document.nil?

      Array(document['download_reviewers_ssim']).reject(&:blank?)
    end

    def batch_user_ms_id
      @batch_user_ms_id ||= User.batch_user.ms_id
    end
  end
end
