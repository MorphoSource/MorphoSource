module Morphosource
  class ReviewedMediaSearchService
    def self.call(params = {})
      new(params).call
    end

    def initialize(params = {})
      @ms_id = params[:ms_id]
    end

    # @return [Array<Hash>] Media documents the User reviews directly or through an organization,
    #   including documents indexed before download_reviewer_mode_ssi, matched by owner
    def call
      return [] if @ms_id.blank?

      organization_ids = ActiveFedora::SolrService.query('has_model_ssim:OrganizationCollection',
        fq: ["download_reviewers_ssim:#{Morphosource::SolrService.prepare_value(@ms_id)}"],
        fl: 'id', rows: 999999, method: :post).map { |org| org['id'] }
      identities = [@ms_id] + organization_ids.map { |id| "#{Morphosource::MediaMetadata::ORG_COLLECTION_TOKEN_PREFIX}#{id}" }
      owners = [@ms_id] + organization_ids
      ActiveFedora::SolrService.query('has_model_ssim:Media',
        fq: ["#{any_of('download_reviewers_ssim', identities)} OR " \
             "(#{any_of('user_with_ownership_ssi', owners)} AND -download_reviewer_mode_ssi:[* TO *])"],
        rows: 999999, method: :post)
    end

    private

      def any_of(field, values)
        "#{field}:(#{values.map { |value| Morphosource::SolrService.prepare_value(value) }.join(' OR ')})"
      end
  end
end
