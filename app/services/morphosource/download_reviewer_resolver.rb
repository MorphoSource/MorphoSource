# frozen_string_literal: true

module Morphosource
  # Expands Media#download_reviewers tokens into reviewer ms_ids. Memoizes organizations,
  # so use one instance per operation, not per media.
  #
  # @example
  #   resolver = Morphosource::DownloadReviewerResolver.new
  #   resolver.reviewers_by_media_id(media_ids)
  #   media_docs.map { |doc| resolver.call(doc) }
  class DownloadReviewerResolver
    TOKEN_PREFIX = Morphosource::MediaMetadata::ORG_COLLECTION_TOKEN_PREFIX
    MEDIA_FIELDS = %w[id has_model_ssim download_reviewers_ssim download_reviewer_mode_ssi user_with_ownership_ssi].freeze

    Resolution = Struct.new(:ms_ids, :fallback, keyword_init: true)

    def initialize
      @organization_reviewers = {}
      @owner_organizations = {}
    end

    # @param media [Media, SolrDocument] anything answering #download_reviewers
    # @return [Array<String>] reviewer ms_ids; never empty, falling back to the batch User
    def call(media)
      resolve(media.download_reviewers { |owner_id| owner_organization?(owner_id) }).ms_ids
    end

    # @param identities [Array<String>] User ms_ids and/or "org_collection:<id>" tokens
    # @return [Resolution] live reviewer ms_ids, and whether they are the batch User fallback
    def resolve(identities)
      tokens, ms_ids = Array(identities).reject(&:blank?).uniq
                                        .partition { |identity| identity.start_with?(TOKEN_PREFIX) }

      candidates = ms_ids + tokens.flat_map { |token| organization_reviewers(token.delete_prefix(TOKEN_PREFIX)) }
      reviewers = existing_users(candidates.uniq)
      return Resolution.new(ms_ids: reviewers, fallback: false) if reviewers.present?

      Resolution.new(ms_ids: [batch_user_ms_id], fallback: true)
    end

    # @param media_ids [Array<String>]
    # @return [Hash{String => Array<String>}] reviewer ms_ids by Media id; Media missing from Solr are absent
    def reviewers_by_media_id(media_ids)
      return {} if media_ids.empty?

      documents = ActiveFedora::SolrService.query('has_model_ssim:Media', fq: ["{!terms f=id}#{media_ids.join(',')}"],
                                                  fl: MEDIA_FIELDS.join(','), rows: media_ids.size, method: :post)
      documents.to_h { |document| [document['id'], call(::SolrDocument.new(document.to_h))] }
    end

    private

    def owner_organization?(owner_id)
      @owner_organizations.fetch(owner_id) do
        @owner_organizations[owner_id] = OrganizationCollection.exists?(owner_id)
      end
    end

    # Includes organization reviewers: an organization's Solr document can name deleted Users.
    def existing_users(ms_ids)
      return [] if ms_ids.empty?

      ms_ids & User.where(ms_id: ms_ids).pluck(:ms_id)
    end

    def organization_reviewers(organization_id)
      @organization_reviewers[organization_id] ||= load_organization_reviewers(organization_id)
    end

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
