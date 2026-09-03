# frozen_string_literal: true

module Morphosource
  # Reviewer Resolution: turns a media's Reviewer Identity into the Users who review its
  # Download Requests right now. See CONTEXT.md for both terms.
  #
  # Media#download_reviewers deliberately stops at the organization boundary, emitting an
  # "org_collection:<id>" token instead of that organization's Users, so that a change to the
  # organization's managers does not require reindexing every media it reviews. This service
  # follows those tokens, reading each organization's reviewers from Solr.
  #
  # Memoization lives on the instance, so use **one instance per logical operation** — one per
  # Morphosource::CartItems#make_request call, one per batch of media in a lifecycle job, one
  # per rendered page. A fresh instance per media reloads the same organization once per media,
  # which is the cost this class exists to avoid.
  #
  #   resolver = Morphosource::DownloadReviewerResolver.new
  #   media_docs.map { |doc| resolver.call(doc) }
  class DownloadReviewerResolver
    TOKEN_PREFIX = Morphosource::MediaMetadata::ORG_COLLECTION_TOKEN_PREFIX

    def initialize
      @organization_reviewers = {}
    end

    # @param media [Media, SolrDocument] anything answering #download_reviewers
    # @return [Array<String>] ms_ids of the Users who may decide this media's Download
    #   Requests. Never empty: when nothing resolves, the batch User is returned so the
    #   requests reach MorphoSource staff rather than nobody.
    def call(media)
      tokens, ms_ids = Array(media.download_reviewers).reject(&:blank?).uniq
                                                      .partition { |identity| identity.start_with?(TOKEN_PREFIX) }

      reviewers = existing_users(ms_ids) +
                  tokens.flat_map { |token| organization_reviewers(token.delete_prefix(TOKEN_PREFIX)) }

      # Applied once to the whole union, never per token: a media reviewed by one live
      # organization and one deleted one must resolve to the live organization's reviewers
      # alone, not to those plus a system account.
      reviewers.uniq.presence || [batch_user_ms_id]
    end

    private

    # Stored ms_ids naming a User row that no longer exists contribute nothing, which lets the
    # batch User fallback see the media as unreviewed.
    def existing_users(ms_ids)
      return [] if ms_ids.empty?

      User.where(ms_id: ms_ids).pluck(:ms_id)
    end

    def organization_reviewers(organization_id)
      @organization_reviewers[organization_id] ||= load_organization_reviewers(organization_id)
    end

    # Read from Solr rather than Fedora: the lifecycle jobs resolve media in batches of
    # several hundred and must not touch Fedora at all.
    #
    # A dangling token — one naming an OrganizationCollection that no longer exists — resolves
    # to no users silently. Raising would fail the whole batch, and fail it again on every
    # retry, so one deleted organization would permanently block the rest.
    def load_organization_reviewers(organization_id)
      document = ActiveFedora::SolrService.query("id:#{organization_id}",
                                                 fq: ['has_model_ssim:OrganizationCollection'],
                                                 rows: 1).first
      return [] if document.nil?

      Array(document['download_reviewers_ssim']).reject(&:blank?)
    end

    # User.batch_user routes through find_or_create_system_user and cannot return nil.
    # Memoized so a large batch does not issue one lookup per media.
    def batch_user_ms_id
      @batch_user_ms_id ||= User.batch_user.ms_id
    end
  end
end
