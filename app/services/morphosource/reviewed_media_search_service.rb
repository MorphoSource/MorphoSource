module Morphosource
  class ReviewedMediaSearchService
    def self.call(params = {})
      new(params).call
    end

    def initialize(params = {})
      @ms_id = params[:ms_id]
    end

    def call
      return [] if @ms_id.blank?

      organizations = ActiveFedora::SolrService.query('has_model_ssim:OrganizationCollection',
        fq: ["download_reviewers_ssim:#{Morphosource::SolrService.prepare_value(@ms_id)}"],
        fl: 'id', rows: 999999, method: :post)
      identities = [@ms_id] + organizations.map { |org| "org_collection:#{org['id']}" }
      clauses = identities.map { |id| "download_reviewers_ssim:#{Morphosource::SolrService.prepare_value(id)}" }
      ActiveFedora::SolrService.query('has_model_ssim:Media',
        fq: ["(#{clauses.join(' OR ')})"], rows: 999999, method: :post)
    end
  end
end
